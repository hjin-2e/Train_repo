
# ==============================================================================
# AWS VPN Tunnel Outputs for Azure Integration
# ==============================================================================
output "vpn_tunnel1_address" {
  description = "AWS VPN Tunnel 1 Public IP"
  value       = module.networking.vpn_tunnel1_address
}

output "vpn_tunnel1_preshared_key" {
  description = "AWS VPN Tunnel 1 Pre-Shared Key"
  value       = module.networking.vpn_tunnel1_preshared_key
  sensitive   = true
}

output "vpn_tunnel2_address" {
  description = "AWS VPN Tunnel 2 Public IP"
  value       = module.networking.vpn_tunnel2_address
}

output "vpn_tunnel2_preshared_key" {
  description = "AWS VPN Tunnel 2 Pre-Shared Key"
  value       = module.networking.vpn_tunnel2_preshared_key
  sensitive   = true
}
