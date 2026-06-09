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

  storage_type = "aurora-iopt1"

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

  performance_insights_enabled    = true
  monitoring_interval             = 60
}
