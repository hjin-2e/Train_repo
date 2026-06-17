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

  # VNet 프라이빗 통합 (Public 접근 차단)
  delegated_subnet_id    = var.mysql_subnet_id
  private_dns_zone_id    = var.mysql_private_dns_zone_id

  # 계정 정보
  administrator_login    = var.db_user
  administrator_password = var.db_password

  # 엔진 버전 (AWS Aurora MySQL 8.0 호환)
  version                = "8.0.21"

  # 비용 최적화 스펙 (DR Passive이므로 최소 사양)
  sku_name               = var.db_sku_name

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

  zone = "1"

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql-dr"
    Environment = var.environment
    Role        = "DR-Passive"
  }
}

# ==============================================================================
# 서버 파라미터 설정
# ==============================================================================

# SSL 강제 (DMS 및 App Service 연결 시 암호화 전송 보장)
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  value               = "ON"
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

# lower_case_table_names (AWS Aurora와 동일 — 대소문자 구분 없이 테이블명 취급)
resource "azurerm_mysql_flexible_server_configuration" "lower_case_table_names" {
  name                = "lower_case_table_names"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.dr.name
  value               = "1"
}

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
