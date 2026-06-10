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
# [불필요] WAF logging configuration이 networking/waf.tf로 이동
# ==================
# variable "waf_web_acl_arn" {
#   description = "WAF Web ACL ARN"
#   type        = string
# }