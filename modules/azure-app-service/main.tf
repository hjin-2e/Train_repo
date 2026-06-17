# Azure Service Plan
resource "azurerm_service_plan" "app_plan" {
  name                = "${var.project_name}-${var.environment}-asp"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Azure Linux Web App (App Service)
resource "azurerm_linux_web_app" "web_app" {
  name                = "${var.project_name}-${var.environment}-app-service"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = false
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

    "READ_ONLY_MODE"  = "true"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.web_app.id
  subnet_id      = var.app_subnet_id
}
