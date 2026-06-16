variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "koreacentral"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "gateway_subnet_cidr" {
  description = "Azure GatewaySubnet CIDR (VNet 내부, /27 이상 권장)"
  type        = string
  default     = "10.1.255.0/27"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block (Local Network Gateway address_space)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpn_tunnel1_address" {
  description = "AWS VPN Connection Tunnel 1 public IP (networking 모듈의 vpn_tunnel1_address output)"
  type        = string
  default     = ""
}

variable "aws_vpn_tunnel1_preshared_key" {
  description = "AWS VPN Connection Tunnel 1 Pre-Shared Key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_vpn_tunnel2_address" {
  description = "AWS VPN Connection Tunnel 2 public IP (networking 모듈의 vpn_tunnel2_address output, 이중화용)"
  type        = string
  default     = ""
}

variable "aws_vpn_tunnel2_preshared_key" {
  description = "AWS VPN Connection Tunnel 2 Pre-Shared Key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_subnet_cidr" {
  description = "CIDR block for Azure App Service subnet (delegated to Microsoft.Web/serverFarms)"
  type        = string
  default     = "10.1.1.0/24"
}

variable "mysql_subnet_cidr" {
  description = "CIDR block for Azure MySQL Flexible Server subnet (delegated to Microsoft.DBforMySQL/flexibleServers)"
  type        = string
  default     = "10.1.2.0/24"
}

variable "enable_vpn_gateway" {
  description = "Set to true to create the VPN Gateway and connections (prod-only recommended to save cost)"
  type        = bool
  default     = true
}


