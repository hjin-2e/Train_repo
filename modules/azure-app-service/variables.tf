variable "project_name" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g. dev, prod)"
  type        = string
}

variable "azure_location" {
  description = "The Azure region where the App Service should be deployed"
  type        = string
  default     = "koreacentral"
}

variable "resource_group_name" {
  description = "The Azure Resource Group name"
  type        = string
}

variable "sku_name" {
  description = "App Service Plan SKU (B1은 VNet Integration 미지원, S1 이상 필요)"
  type        = string
  default     = "S1"
}

variable "app_subnet_id" {
  description = "The Azure Subnet ID for VNet Integration (null = VNet Integration 비활성화)"
  type        = string
  default     = null
}
