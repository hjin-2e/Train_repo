# Train_Infra\compute_infra\variables.tf

variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "Target deployment environment (dev/prod)"
  type        = string
}

variable "developer_ips" {
  description = "Developer IP addresses"
  type        = list(string)
}