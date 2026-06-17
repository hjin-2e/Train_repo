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

variable "create_s3_buckets" {
  description = "Whether to create S3 buckets in this module"
  type        = bool
  default     = true
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

# ==================
# Fluent Bit & IRSA
# ==================
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN for IRSA"
  type        = string
  default     = ""
}

variable "oidc_provider" {
  description = "OIDC Provider for IRSA"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "cloudtrail_bucket_name" {
  description = "CloudTrail 로그 S3 버킷 이름 (Athena Glue Crawler 스캔 대상, 미입력 시 CloudTrail Crawler 비활성화)"
  type        = string
  default     = ""
}