# Train_Infra\compute_infra\variables.tf

variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "Target deployment environment (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}

variable "subnet_ids" {
  description = "List of Private Subnet IDs for EKS"
  type        = list(string)
}

variable "ops_logs_bucket_id" {
  description = "S3 bucket ID for ALB access logs"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group ID for ALB"
  type        = string
}

variable "eks_bastion_role_arn" {
  description = "IAM Role ARN of the EKS Bastion"
  type        = string
}

variable "eks_bastion_sg_id" {
  description = "Security Group ID of the EKS Bastion (to allow cluster API access on 443)"
  type        = string
}

variable "acm_alb_certificate_arn" {
  description = "ACM Certificate ARN for ALB HTTPS"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}