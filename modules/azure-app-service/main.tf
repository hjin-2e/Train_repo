# Azure Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "${var.project_name}-${var.environment}-asp"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

# Azure Linux Web App (App Service)
resource "azurerm_linux_web_app" "web_app" {
  name                = "${var.project_name}-${var.environment}-app-service"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  service_plan_id     = azurerm_service_plan.app_plan.id

  # S1 이상일 때 VNet Integration 활성화 (null이면 비활성화 - dev/B1용)
  virtual_network_subnet_id = var.app_subnet_id

  site_config {
    always_on = var.sku_name == "B1" ? false : true
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    "ENV"             = var.environment
    "PROJECT"         = var.project_name
    "WEBSITES_PORT"   = "8080"

    # DB 연결 정보 (Azure MySQL Flexible Server)
    "DB_HOST"         = var.db_host
    "DB_PORT"         = var.db_port
    "DB_USER"         = var.db_user
    "DB_PASSWORD"     = var.db_password
    "DB_NAME"         = var.db_name

    # DR 모드 설정
    # Azure 환경(DR)은 어떠한 경우에도 쓰기(예매/결제)가 불가하며 오직 '조회(읽기)' 전용으로 동작
    "READ_ONLY_MODE"  = "true"
  }
}
