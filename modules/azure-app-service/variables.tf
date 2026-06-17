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

# DB 연결 정보
variable "db_host" {
  description = "Azure MySQL Flexible Server FQDN"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "MySQL 포트 번호"
  type        = string
  default     = "3306"
}

variable "db_user" {
  description = "MySQL 관리자 계정 이름"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "MySQL 관리자 계정 비밀번호"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_name" {
  description = "MySQL 데이터베이스 이름"
  type        = string
  default     = "trail_db"
}
