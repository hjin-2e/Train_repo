# DMS는 DR(prod) 전용. dev에서는 생성하지 않음 (dms-vpc-role 등 계정 전역 IAM Role 중복 방지)
locals {
  dms_enabled = var.environment == "prod"
}

# DMS 복제 인스턴스
resource "aws_dms_replication_instance" "dms_worker" {
  count                      = local.dms_enabled ? 1 : 0
  replication_instance_id    = "trail-dms-instance"
  replication_instance_class = var.dms_instance_class
  allocated_storage          = 20
  publicly_accessible        = false

  # AZ 단일 장애 시 자동 페일오버 (AZ-a ↔ AZ-c)
  # 서브넷 그룹이 private_a + private_c 두 AZ를 커버하므로 Standby를 반대 AZ에 자동 배치
  # AZ 2개 모두 장애(AWS 전체 불가) 시에는 Azure MySQL로 수동 전환
  multi_az = true

  vpc_security_group_ids      = [var.dms_sg_id]
  replication_subnet_group_id = var.dms_subnet_group_name
}

# Source 엔드포인트 (출발지: 우리가 방금 만든 Aurora)
resource "aws_dms_endpoint" "source_aurora" {
  count         = local.dms_enabled ? 1 : 0
  endpoint_id   = "source-aurora-mysql"
  endpoint_type = "source"
  engine_name   = "mysql"
  server_name   = aws_rds_cluster.aurora_cluster.endpoint
  port          = 3306
  database_name = "trail_db"
  username      = var.db_admin_user
  password      = var.db_admin_password
}

# Target 엔드포인트 (도착지: Azure MySQL)
# S2S VPN 연결 시 azure_db_endpoint는 Azure VNet 내부 사설 IP/FQDN을 사용 (공개 엔드포인트 아님)
resource "aws_dms_endpoint" "target_azure" {
  count                       = local.dms_enabled ? 1 : 0
  endpoint_id                 = "target-azure-mysql"
  endpoint_type               = "target"
  engine_name                 = "mysql"
  server_name                 = var.azure_db_endpoint
  port                        = 3306
  ssl_mode                    = "require"
  database_name               = "trail_db"
  username                    = var.azure_db_user
  password                    = var.azure_db_password
  extra_connection_attributes = "initstmt=SET FOREIGN_KEY_CHECKS=0;"
}

# 복제 작업 (Task) - 실시간 동기화(CDC)
resource "aws_dms_replication_task" "aurora_to_azure" {
  count                    = local.dms_enabled ? 1 : 0
  replication_task_id      = "trail-dr-replication-task"
  migration_type           = "full-load-and-cdc" # 기존 데이터 + 실시간 변경분 모두 복제
  replication_instance_arn = aws_dms_replication_instance.dms_worker[0].replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source_aurora[0].endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target_azure[0].endpoint_arn

  # 대상 DB(Azure)의 테이블 구조를 지우지 않고 데이터만 넣도록 강제 설정
  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetTablePrepMode = "DO_NOTHING"
    }
  })

  # trail_db 테이블을 복제하는 JSON 룰 (모든 스키마 복제)
  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "include-trail-db"
        object-locator = {
          schema-name = "trail_db"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })
}
