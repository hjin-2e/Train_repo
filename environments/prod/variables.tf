variable "aws_region" {
  description = "Target AWS regoin"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름"
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