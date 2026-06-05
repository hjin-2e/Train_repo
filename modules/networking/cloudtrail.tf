# CloudTrail 로그 저장용 S3 버킷
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.project_name}-cloudtrail-logs"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-cloudtrail-logs"
    Environment = var.environment
  }
}

# S3 버킷 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 버킷 암호화 (KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# S3 버킷 정책 (CloudTrail만 접근 허용)
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudTrail 버킷 확인 권한
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      # CloudTrail 로그 저장 권한
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail KMS 키 정책
resource "aws_kms_key_policy" "cloudtrail" {
  key_id = aws_kms_key.s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 관리자 권한
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      # CloudTrail 암호화 권한
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# 현재 AWS 계정 정보
data "aws_caller_identity" "current" {}

# CloudTrail 생성
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  kms_key_id                    = aws_kms_key.s3.arn
  include_global_service_events = true
  is_multi_region_trail         = var.cloudtrail_multi_region        # 변수 참조
  enable_log_file_validation    = var.cloudtrail_enable_log_validation # 변수 참조

  # CloudWatch Logs 연동
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail.arn

  # 이벤트 선택기 (관리 이벤트)
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    # S3 데이터 이벤트 추적
    data_resource {
  type   = "AWS::S3::Object"
  values = ["${aws_s3_bucket.frontend.arn}/"]
    }

    # Lambda 이벤트 추적
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  tags = {
    Name        = "${var.project_name}-trail"
    Environment = var.environment
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}"
  retention_in_days = var.cloudtrail_retention_days  # 변수 참조

  tags = {
    Name        = "${var.project_name}-cloudtrail-logs"
    Environment = var.environment
  }
}