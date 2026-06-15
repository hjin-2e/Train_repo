variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS OIDC provider"
}

variable "oidc_provider" {
  type        = string
  description = "URL of the EKS OIDC provider (without https:// prefix)"
}

variable "aurora_policy_arn" {
  type        = string
  description = "IAM Policy ARN for Aurora DB access"
}

variable "sqs_policy_arn" {
  type        = string
  description = "IAM Policy ARN for SQS access"
}

variable "elasticache_policy_arn" {
  type        = string
  description = "IAM Policy ARN for ElastiCache access"
}

variable "secrets_policy_arn" {
  type        = string
  description = "IAM Policy ARN for Secrets Manager access"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "cluster_autoscaler_policy_arn" {
  type        = string
  description = "IAM Policy ARN for Cluster Autoscaler (created by eks-cluster module)"
}
