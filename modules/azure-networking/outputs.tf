output "vpn_gateway_public_ip" {
  description = "Azure VPN Gateway 공개 IP (참고용 - 2단계 apply는 enable_azure_vpn=true 시 root의 data.azurerm_public_ip가 동일 값을 자동 조회함)"
  value       = azurerm_public_ip.vpn_gw.ip_address
}

output "vnet_cidr" {
  description = "Azure VNet CIDR block"
  value       = var.azure_vnet_cidr
}

