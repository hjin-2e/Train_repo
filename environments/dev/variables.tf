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

# DB 관련 변수 선언
# variable "db_admin_user" {
#   description = "admin user data"
#   type        = string
# }

# variable "db_admin_password" {
#   description = "admin user password"
#   type        = string
# }

# variable "azure_db_endpoint" {
#   description = "azure database endpoint"
#   type        = string
# }

# variable "azure_db_user" {
#   description = "azure database endpoint"
#   type        = string
# }

# variable "azure_db_password" {
#   description = "azure database endpoint"
#   type        = string
# }
