variable "aws_region" {
  description = "Target aws region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "project name"
  type        = string
  default     = "team-train"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "dev"
}

variable "developer_ips" {
  description = "Allowed public IP list for EKS cluster API access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}