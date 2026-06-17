# ==============================================================================
# AWS Athena & Glue Crawler 연동 (CloudTrail 로그 분석)
# ==============================================================================

# 1. Athena 쿼리 결과 저장용 S3 버킷
resource "aws_s3_bucket" "athena_results" {
  count         = var.create_s3_buckets ? 1 : 0
  bucket        = "${var.project_name}-${var.environment}-athena-results"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-athena-results"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  count  = var.create_s3_buckets ? 1 : 0
  bucket = aws_s3_bucket.athena_results[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Athena 데이터베이스 생성 (카탈로그)
resource "aws_athena_database" "logs_db" {
  count         = var.create_s3_buckets ? 1 : 0
  name          = "${replace(var.project_name, "-", "_")}_${replace(var.environment, "-", "_")}_logs_db"
  bucket        = aws_s3_bucket.athena_results[0].bucket
  force_destroy = true
}

# 3. Athena 워크그룹 생성
resource "aws_athena_workgroup" "logs_workgroup" {
  count = var.create_s3_buckets ? 1 : 0
  name  = "${var.project_name}-${var.environment}-logs-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results[0].bucket}/"
    }
  }
  force_destroy = true
}

# 4. Glue 크롤러 전용 IAM 역할 및 정책
resource "aws_iam_role" "glue_crawler_role" {
  count = var.create_s3_buckets ? 1 : 0
  name  = "${var.project_name}-${var.environment}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# AWS 기본 제공 Glue 서비스 정책 부착
resource "aws_iam_role_policy_attachment" "glue_service" {
  count      = var.create_s3_buckets ? 1 : 0
  role       = aws_iam_role.glue_crawler_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue 크롤러가 CloudTrail S3 버킷을 읽을 수 있도록 정책 추가
resource "aws_iam_role_policy" "glue_cloudtrail_s3_read" {
  count = var.create_s3_buckets && var.cloudtrail_bucket_name != "" ? 1 : 0
  name  = "GlueCloudTrailS3ReadPolicy"
  role  = aws_iam_role.glue_crawler_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = [
        "arn:aws:s3:::${var.cloudtrail_bucket_name}",
        "arn:aws:s3:::${var.cloudtrail_bucket_name}/*"
      ]
    }]
  })
}

# 5. CloudTrail 로그 Glue 크롤러 (API 호출 이력 Athena 쿼리용)
resource "aws_glue_crawler" "cloudtrail_logs_crawler" {
  count         = var.create_s3_buckets && var.cloudtrail_bucket_name != "" ? 1 : 0
  name          = "${var.project_name}-${var.environment}-cloudtrail-crawler"
  role          = aws_iam_role.glue_crawler_role[0].arn
  database_name = aws_athena_database.logs_db[0].name

  s3_target {
    path = "s3://${var.cloudtrail_bucket_name}/AWSLogs/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  tags = {
    Name        = "cloudtrail-logs-crawler"
    Environment = var.environment
  }
}
