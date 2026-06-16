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

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
  default     = "Password123!"
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
  default     = "Admin123!@#"
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

variable "slack_webhook_url" {
  description = "Slack Incoming Webhook URL for Application Error alerts"
  type        = string
  default     = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}

