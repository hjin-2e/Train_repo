variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "team-train"
}

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin123" # Provide a dummy default or expect it to be passed
}
