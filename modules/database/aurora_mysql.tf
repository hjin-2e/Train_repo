# 파라미터 그룹 생성
resource "aws_rds_cluster_parameter_group" "aurora_cluster_pg" {
  name        = "trail-aurora-cluster-pg"
  family      = "aurora-mysql8.0"
  description = "Aurora MySQL 8.0 parameter group for DMS CDC and UTF8mb4"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
  parameter {
    name  = "binlog_row_image"
    value = "full"
  }
  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }
  parameter {
    name         = "lower_case_table_names"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_0900_ai_ci"
  }
}

# Aurora MySQL 클러스터
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "trail-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.04.0"
  database_name      = "trail_db" # 초기 생성될 빈 DB 이름
  master_username    = var.db_admin_user
  master_password    = var.db_admin_password

  storage_type      = "aurora-iopt1"
  storage_encrypted = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.aurora_sg_id]

  # 파라미터 그룹을 클러스터에 연결
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_pg.name

  skip_final_snapshot = true # 테스트용 삭제할 때 스냅샷 안 남기기
}

# Aurora MySQL 인스턴스
resource "aws_rds_cluster_instance" "aurora_instance" {
  count      = 2
  identifier = "trail-aurora-instance-${count.index}"

  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.t4g.medium" # 가성비 인스턴스  
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
}

# RDS 모니터링용 IAM Role 생성
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role"

  # RDS 모니터링 서비스만 이 Role 사용 가능
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# AWS 관리형 정책 연결
# CloudWatch Logs 전송 권한 포함
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring.name
}

# aurora.tf 파일 맨 아래에 추가
resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}-db-secret"

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
    DB_HOST     = aws_rds_cluster.aurora_cluster.endpoint
    DB_NAME     = aws_rds_cluster.aurora_cluster.database_name
  })
}
