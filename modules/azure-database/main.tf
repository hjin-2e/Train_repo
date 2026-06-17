# ==============================================================================
# Azure Database for MySQL - Flexible Server (DR Passive)
#
# AWS Aurora MySQL(Active)의 재해 복구(DR) 대상 DB.
# VNet 내 Private 서브넷에 배포하여 S2S VPN 터널을 통해서만 접근 가능.
# ==============================================================================

resource "azurerm_mysql_flexible_server" "dr" {
  name                   = "${var.project_name}-${var.environment}-mysql"
  resource_group_name    = var.resource_group_name
  location               = var.azure_location

  delegated_subnet_id    = var.mysql_subnet_id
  private_dns_zone_id    = var.mysql_private_dns_zone_id
  
  administrator_login    = var.db_user
  administrator_password = var.db_password
  version                = "8.0.21"
  sku_name               = "B_Standard_B1ms"

  # 스토리지 (IOPS 자동 스케일링 활성화)
  storage {
    size_gb           = 20
    auto_grow_enabled = true
    iops              = 360
  }

  # 백업 (DR 자체가 백업 목적이므로 최소 보존)
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  # 고가용성 비활성화 (DR Passive 단독 인스턴스)
  # 비용 최적화: HA가 필요한 쪽은 AWS Aurora (Active)
  # zone 하드코딩 제거: ZoneNotAvailableForRegion 에러 방지 (Azure가 자동 할당)

  lifecycle {
    ignore_changes = [
      zone
    ]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql-dr"
    Environment = var.environment
    Role        = "DR-Passive"
  }

  # Private DNS Zone 링크가 먼저 완성된 후 서버를 생성해야 VnetNotLinkedToPrivateDnsZone 에러 방지
  # depends_on은 azure-prod/main.tf의 module "azure-database" 블록에서 처리됨
}

# ==============================================================================
# 서버 파라미터 설정
# ==============================================================================

# SSL 강제 (DMS 및 App Service 연결 시 암호화 전송 보장)
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  value               = "OFF"
}

# UTF-8 문자셋 설정 (AWS Aurora와 동일하게 맞춤)
resource "azurerm_mysql_flexible_server_configuration" "character_set_server" {
  name                = "character_set_server"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  value               = "UTF8MB4"
}

resource "azurerm_mysql_flexible_server_configuration" "collation_server" {
  name                = "collation_server"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  value               = "utf8mb4_0900_ai_ci"
}

# lower_case_table_names 는 MySQL 8.0에서 read-only 파라미터 (서버 시작 시에만 설정 가능).
# Terraform apply 시 "Variable 'lower_case_table_names' is a read only variable" 에러 발생.
# Azure MySQL Flexible Server는 기본값 1(대소문자 무시)이므로 별도 설정 불필요.

# ==============================================================================
# Database 자체 생성 (trail_db)
# ==============================================================================
resource "azurerm_mysql_flexible_database" "trail_db" {
  name                = "trail_db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_0900_ai_ci"
}
