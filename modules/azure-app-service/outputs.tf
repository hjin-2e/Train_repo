output "app_service_name" {
  description = "The name of the Azure App Service"
  value       = azurerm_linux_web_app.web_app.name
}

output "app_service_default_hostname" {
  description = "The default hostname of the App Service (e.g. app-service.azurewebsites.net)"
  value       = azurerm_linux_web_app.web_app.default_hostname
}

output "app_service_id" {
  description = "The Resource ID of the App Service"
  value       = azurerm_linux_web_app.web_app.id
}
