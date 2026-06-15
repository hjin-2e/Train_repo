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

variable "cloudfront_domain_name" {
  description = "CloudFront domain name"
  type        = string
  default     = ""
}

variable "cloudfront_zone_id" {
  description = "CloudFront hosted zone ID"
  type        = string
  default     = "Z2FDTNDATAQYW2"
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID"
  type        = string
  default     = ""
}

# DB 관련
variable "db_admin_user" {
  description = "Database admin username"
  type        = string
  default     = "admin"
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  type        = string
  default     = ""
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

variable "azure_db_password" {
  description = "Azure database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "notification_email" {
  description = "Notification receiver email"
  type        = string
  default     = ""
}

variable "verified_email_or_domain" {
  description = "Verified SES sender email or domain"
  type        = string
  default     = ""
}

