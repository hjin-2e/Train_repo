output "vpn_gateway_public_ip" {
  description = "The public IP address of the Azure VPN Gateway to be registered as the AWS Customer Gateway"
  value       = module.azure-networking.vpn_gateway_public_ip
}

output "app_service_url" {
  description = "The default hostname (URL) of the Azure production App Service"
  value       = module.azure-app-service.app_service_default_hostname
}

output "mysql_server_fqdn" {
  description = "Azure MySQL Flexible Server FQDN (DMS 타겟 엔드포인트 및 백엔드 DB_HOST로 사용)"
  value       = module.azure-database.mysql_server_fqdn
}

output "mysql_database_name" {
  description = "Azure MySQL에 생성된 데이터베이스 이름 (DMS table_mappings schema-name으로 사용)"
  value       = module.azure-database.mysql_database_name
}

output "mysql_subnet_id" {
  description = "The dedicated subnet ID for Azure Database for MySQL, to be provided to the DB administrator"
  value       = module.azure-networking.mysql_subnet_id
}

output "mysql_private_dns_zone_id" {
  description = "The Private DNS Zone ID for Azure Database for MySQL, to be provided to the DB administrator"
  value       = module.azure-networking.mysql_private_dns_zone_id
}