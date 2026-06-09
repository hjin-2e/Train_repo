# Aurora DB 암호화 키
resource "aws_kms_key" "aurora" {
  description             = "Aurora DB encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-aurora-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${var.project_name}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

# S3 암호화 키 (로그, 프론트엔드)
resource "aws_kms_key" "s3" {
  description             = "S3 encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-s3-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

# Redis 암호화 키
resource "aws_kms_key" "redis" {
  description             = "Redis encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-redis-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "redis" {
  name          = "alias/${var.project_name}-redis"
  target_key_id = aws_kms_key.redis.key_id
}

# ==================
# Secrets Manager
# ==================
resource "aws_secretsmanager_secret" "db" {
  name       = "${var.project_name}-db-secret"
  kms_key_id = aws_kms_key.aurora.arn

  tags = {
    Name        = "${var.project_name}-db-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    DB_USER     = var.db_admin_user
    DB_PASSWORD = var.db_admin_password
    DB_HOST     = var.aurora_endpoint
    DB_NAME     = "trail_db"
  })
}