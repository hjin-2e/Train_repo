output "vpn_gateway_public_ip" {
  description = "Azure VPN Gateway 공개 IP (enable_vpn_gateway=false 시 null 반환)"
  value       = one(azurerm_public_ip.vpn_gw[*].ip_address)
}

output "vnet_cidr" {
  description = "Azure VNet CIDR block"
  value       = var.azure_vnet_cidr
}

output "resource_group_name" {
  description = "Azure Resource Group name"
  value       = azurerm_resource_group.vpn.name
}

output "vnet_name" {
  description = "Azure VNet name"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "Azure VNet ID"
  value       = azurerm_virtual_network.main.id
}

output "app_subnet_id" {
  description = "Azure App Service VNet Integration Subnet ID"
  value       = azurerm_subnet.app.id
}

output "mysql_subnet_id" {
  description = "Azure MySQL Subnet ID"
  value       = azurerm_subnet.mysql.id
}

output "mysql_private_dns_zone_id" {
  description = "Azure MySQL Private DNS Zone ID"
  value       = azurerm_private_dns_zone.mysql.id
}


