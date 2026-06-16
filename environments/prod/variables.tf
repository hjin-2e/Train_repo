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
  default     = ""
}

# ==================
# Azure S2S VPN (DR 연동)
# ==================
variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR block for S2S VPN"
  type        = string
  default     = ""
}

variable "enable_azure_vpn" {
  description = "Azure VPN Gateway IP 조회 활성화 여부. false: 1단계 (azure-networking 모듈만 먼저 apply), true: 2단계 (azurerm_public_ip를 Azure API에서 직접 조회해 AWS 측 Customer Gateway 생성)"
  type        = bool
  default     = false
}

# Azure environments에서 출력된 값
variable "azure_vpn_gateway_ip" {
  description = "Azure VPN Gateway Public IP"
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

variable "route53_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
}
