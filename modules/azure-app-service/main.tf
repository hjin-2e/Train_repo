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
    "ENV"           = var.environment
    "PROJECT"       = var.project_name
    "WEBSITES_PORT" = "8080"
  }
}
