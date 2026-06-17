# ==============================================================================
# AWS Athena & Glue Crawler 연동 (ALB 접속 로그 자동 분석)
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

