variable "project_name" {
  description = "The name of the project used for resource naming prefixes"
  type        = string
}

variable "environment" {
  description = "The deployment environment stage (e.g., dev, stage, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the resources will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster and ALB reside"
  type        = string
}

variable "cluster_name" {
  description = "The name of the target EKS cluster to inject the ALB controller"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider for IAM Roles for Service Accounts (IRSA)"
  type        = string
}