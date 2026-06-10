# ==============================================================================
# 통합 운영 로그 버킷 (ops-logs)
# ALB 액세스 로그, CloudFront 로그 등 인프라 운영 로그 통합 저장소
# ==============================================================================

# 1. 통합 인프라/운영 로그 저장용 S3 버킷
resource "aws_s3_bucket" "ops_logs" {
  bucket        = "${var.project_name}-ops-logs"
  force_destroy = true # 프로젝트 종료 후 삭제 용이성을 위해 설정

  tags = {
    Name        = "${var.project_name}-ops-logs"
    Environment = var.environment
  }
}

# 2. S3 버킷 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "ops_logs" {
  bucket = aws_s3_bucket.ops_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. 버킷 소유권 설정 (CloudFront/ALB 로그 적재를 위해 필수)
resource "aws_s3_bucket_ownership_controls" "ops_logs" {
  bucket = aws_s3_bucket.ops_logs.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# 4. 버킷 ACL 설정 (Private 유지하되 라이터 권한 허용 준비)
resource "aws_s3_bucket_acl" "ops_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.ops_logs]

  bucket = aws_s3_bucket.ops_logs.id
  acl    = "private"
}

# 5. 통합 로그 버킷 정책 (ALB가 로그를 적재할 수 있도록 허용)
resource "aws_s3_bucket_policy" "ops_logs_policy" {
  bucket = aws_s3_bucket.ops_logs.id

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
        Resource = "${aws_s3_bucket.ops_logs.arn}/alb/AWSLogs/*"
      }
    ]
  })
}
