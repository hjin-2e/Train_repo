# ==============================================================================
# 통합 운영 로그 버킷 (ops-logs)
# ALB 액세스 로그, CloudFront 로그 등 인프라 운영 로그 통합 저장소
# cloudtrail-logs 버킷은 modules/networking/cloudtrail.tf 에서 생성 (중복 제거)
# ==============================================================================

# 1. 통합 인프라/운영 로그 저장용 S3 버킷
resource "aws_s3_bucket" "ops_logs" {
  count         = var.create_s3_buckets ? 1 : 0
  bucket        = "${var.project_name}-${var.environment}-ops-logs"
  force_destroy = true # 프로젝트 종료 후 삭제 용이성을 위해 설정

  tags = {
    Name        = "${var.project_name}-${var.environment}-ops-logs"
    Environment = var.environment
  }
}

# 2. S3 버킷 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "ops_logs" {
  count  = var.create_s3_buckets ? 1 : 0
  bucket = aws_s3_bucket.ops_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. 버킷 소유권 설정 (CloudFront/ALB 로그 적재를 위해 필수)
resource "aws_s3_bucket_ownership_controls" "ops_logs" {
  count  = var.create_s3_buckets ? 1 : 0
  bucket = aws_s3_bucket.ops_logs[0].id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# 4. 버킷 ACL 설정 (Private 유지하되 라이터 권한 허용 준비)
resource "aws_s3_bucket_acl" "ops_logs" {
  count      = var.create_s3_buckets ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.ops_logs]

  bucket = aws_s3_bucket.ops_logs[0].id
  acl    = "log-delivery-write"
}

# 5. 통합 로그 버킷 정책 (ALB가 로그를 적재할 수 있도록 허용)
resource "aws_s3_bucket_policy" "ops_logs_policy" {
  count  = var.create_s3_buckets ? 1 : 0
  bucket = aws_s3_bucket.ops_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBAccessLogs"
        Effect = "Allow"
        Principal = {
          # 600734575887은 AWS가 지정한 서울 리전(ap-northeast-2) 전용 ELB 서비스 계정 ID입니다.
          AWS = "arn:aws:iam::600734575887:root"
        }
        Action = "s3:PutObject"
        # ingress.yaml에서 지정한 prefix인 "alb" 경로 하위에만 쓰기 권한을 부여합니다.
        Resource = "${aws_s3_bucket.ops_logs[0].arn}/alb/AWSLogs/*"
      }
    ]
  })
}

# ==============================================================================
# Fluent Bit & IRSA for CloudWatch Logs
# ==============================================================================

# Fluent Bit 파드가 CloudWatch Logs에 로그를 전송하기 위한 IAM Role (IRSA)
resource "aws_iam_role" "fluent_bit" {
  count = var.oidc_provider_arn != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:logging:fluent-bit"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-fluent-bit-role"
    Environment = var.environment
  }
}

# CloudWatch Logs 접근 권한을 가진 AWS 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch" {
  count      = var.oidc_provider_arn != "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.fluent_bit[0].name
}

# Fluent Bit Helm Release
resource "helm_release" "fluent_bit" {
  count            = var.oidc_provider_arn != "" ? 1 : 0
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  namespace        = "logging"
  create_namespace = true

  # IRSA Service Account 연결
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.fluent_bit[0].arn
  }

  # CloudWatch로 보내기 위한 Fluent Bit config 설정
  set {
    name  = "config.outputs"
    value = <<EOF
[OUTPUT]
    Name cloudwatch_logs
    Match *
    region ${var.aws_region}
    log_group_name /eks/${var.cluster_name}/containers
    log_stream_prefix fluent-bit-
    auto_create_group On
EOF
  }
}


