variable "aws_region" {
  description = "Target aws region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "team-train"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "prod"
}

variable "developer_ips" {
  description = "Allowed public IP list for EKS cluster API access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# DB 관련
variable "db_admin_user" {
  description = "Database admin username"
  type        = string
  default     = "admin"
}

variable "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  type        = string
  default     = ""
}

variable "redis_auth_token" {
  description = "Redis authentication token"
  type        = string
  sensitive   = true
  default     = "SecureRedisToken123!"
}

# Azure 관련
variable "azure_db_endpoint" {
  description = "Azure database endpoint"
  type        = string
  default     = ""
}

variable "azure_db_user" {
  description = "Azure database username"
  type        = string
  default     = ""
}

variable "notification_email" {
  description = "Notification receiver email"
  type        = string
  default     = "admin@example.com"
}

variable "verified_email_or_domain" {
  description = "Verified SES sender email or domain"
  type        = string
  default     = "admin@example.com"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR block for S2S VPN"
  type        = string
  default     = ""
}



# ==================
# SES Email 발송
# ==================
variable "domain_name" {
  type        = string
  default     = "team-train.cloud"
  description = "SES 이메일 발송에 사용할 도메인"
}

