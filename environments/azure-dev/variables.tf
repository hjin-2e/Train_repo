variable "project_name" {
  description = "Project name"
  type        = string
  default     = "team-train"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "dev"
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

variable "app_subnet_cidr" {
  description = "CIDR block for App Service integration subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "mysql_subnet_cidr" {
  description = "CIDR block for MySQL subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "gateway_subnet_cidr" {
  description = "Azure GatewaySubnet CIDR (for potential VPN Gateway in future)"
  type        = string
  default     = "10.1.255.0/27"
}

# Azure MySQL DR 계정 정보
variable "azure_db_user" {
  description = "Azure MySQL 관리자 계정 이름"
  type        = string
  default     = "azureadmin"
}

variable "azure_db_password" {
  description = "Azure MySQL 관리자 계정 비밀번호"
  type        = string
  sensitive   = true
  default     = "Password123!"
}
