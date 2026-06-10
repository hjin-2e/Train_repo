# ==================
# 공통 변수
# ==================
variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev / prod)"
  type        = string
}

# ==================
# 로그 보존 기간
# ==================
variable "log_retention_days" {
  description = "CloudWatch Log Group retention period in days (e.g. 7, 14, 30, 90)"
  type        = number
  default     = 7
}

# ==================
# WAF 의존성
# ==================
variable "waf_web_acl_arn" {
  description = <<EOT
WAF Web ACL ARN to attach logging configuration.
Provided from module.networking.waf_arn (networking 모듈 output).
WAF는 CloudFront 연동이므로 us-east-1 리전의 ARN이어야 합니다.
EOT
  type        = string
}
