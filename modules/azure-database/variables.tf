variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "koreacentral"
}

# 네트워크 참조 (azure-networking 모듈에서 전달)
variable "resource_group_name" {
  description = "Azure Resource Group name (azure-networking 모듈에서 생성된 RG)"
  type        = string
}

variable "mysql_subnet_id" {
  description = "Azure MySQL 전용 서브넷 ID (delegated to Microsoft.DBforMySQL/flexibleServers)"
  type        = string
}

variable "mysql_private_dns_zone_id" {
  description = "Azure MySQL Private DNS Zone ID (VNet 내부 DNS 해석용)"
  type        = string
}

# DB 계정 정보
variable "db_user" {
  description = "MySQL 관리자 계정 이름"
  type        = string
}

variable "db_password" {
  description = "MySQL 관리자 계정 비밀번호"
  type        = string
  sensitive   = true
}