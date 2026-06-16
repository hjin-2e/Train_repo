output "app_service_url" {
  description = "The default hostname (URL) of the Azure development App Service"
  value       = module.azure-app-service.app_service_default_hostname
}
