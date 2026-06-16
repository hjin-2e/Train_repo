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

variable "app_subnet_id" {
  description = "The Azure Subnet ID for VNet Integration"
  type        = string
}
