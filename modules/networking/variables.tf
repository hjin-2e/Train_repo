variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "developer_ips" {
  description = "List of developer IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # 나중에 실제 IP로 변경
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

#엔드포인트 db 활성화되면 주석 해제 하기

# variable "aurora_endpoint" {
#   description = "Aurora cluster endpoint"
#   type        = string
#   default     = ""
# }


# SSH 접속할 때 사용할 공개키 파일 경로
variable "bastion_public_key_path" {
  description = "Path to the Bastion SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"  # 로컬 PC의 공개키 기본 경로
}

# Bastion을 퍼블릭 서브넷에 올리기 var.public_subnet_ids[0]로 설정해놨음 
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
  # 앞서 network 모듈에서 만든 public_a, public_c 서브넷 ID가 들어옴
}

#  Bastion에 적용할 보안그룹 ID
variable "bastion_sg_id" {
  description = "Bastion Security Group ID"
  type        = string
  default     = "" 
}


#iam + kms 
variable "aurora_kms_key_arn" {
  description = "Aurora KMS Key ARN"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  type        = string
  default     = ""
}

variable "eks_oidc_provider" {
  description = "EKS OIDC Provider URL"
  type        = string
  default     = ""
}

# ==================
# CloudTrail 관련 변수
# ==================
variable "cloudtrail_retention_days" {
  description = "Retention period for CloudTrail logs in days" 
  type        = number
  default     = 90
}

variable "cloudtrail_enable_log_validation" {
  description = "Whether to enable log file integrity validation for CloudTrail" 
  type        = bool
  default     = true
}

variable "cloudtrail_multi_region" {
  description = "Whether the CloudTrail is created for multi-region" 
  default     = true
}


# ==================
# EKS 관련 변수 (EKS Connection Settings)
# ==================
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""  # Will be provided after EKS cluster is created
}

variable "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster API server"
  type        = string
  default     = ""  # Will be provided after EKS cluster is created
}

variable "eks_cluster_ca" {
  description = "The base64 encoded certificate authority data for the EKS cluster"
  type        = string
  default     = ""  # Will be provided after EKS cluster is created
}

variable "eks_cluster_token" {
  description = "The authentication token to access the EKS cluster API"
  type        = string
  default     = ""  # Will be provided after EKS cluster is created
}

# ==================
# IRSA Pod Role ARN 변수
# ==================
variable "booking_pod_role_arn" {
  description = "IAM Role ARN for the Booking Service Pod"
  type        = string
  default     = ""
}

variable "user_pod_role_arn" {
  description = "IAM Role ARN for the User Service Pod"
  type        = string
  default     = ""
}

variable "payment_pod_role_arn" {
  description = "IAM Role ARN for the Payment Service Pod"
  type        = string
  default     = ""
}

# ==================
# DB & Redis Subnet 변수
# ==================
variable "db_subnet_ids" {
  description = "List of subnet IDs for DB and ElastiCache subnet groups"
  type        = list(string)
  default     = []
}