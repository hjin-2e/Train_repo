variable "project_name" {
  description = "project_name"
  type        = string
  default     = "team-train"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "prod"
}

variable "azure_location" {
  description = "Target Azure region"
  type        = string
  default     = "koreacentral"
}

variable "azure_vnet_cidr" {
  description = "The CIDR block for the Azure Virtual Network"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aws_vpc_cidr" {
  description = "The CIDR block of the AWS VPC for Local Network Gateway routing"
  type        = string
  default     = "10.0.0.0/16"
}

