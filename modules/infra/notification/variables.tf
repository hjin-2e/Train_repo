variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue to be connected as a trigger"
  type        = string
}

variable "sqs_queue_name" {
  description = "The name of the SQS queue for CloudWatch metric monitoring"
  type        = string
}

variable "notification_email" {
  description = "The email address to receive failure alarm notifications"
  type        = string
}

variable "verified_email_or_domain" {
  description = "The verified email address or domain in SES to be used for sending emails"
  type        = string
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
}