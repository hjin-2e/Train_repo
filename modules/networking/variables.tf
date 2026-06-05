variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
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
  # 앞서 network 모듈에서 만든 public_a, public_c 서브넷 ID가 들어옴
}

#  Bastion에 적용할 보안그룹 ID
variable "bastion_sg_id" {
  description = "Bastion Security Group ID"
  type        = string
}