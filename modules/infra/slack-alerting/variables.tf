variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack Incoming Webhook URL for Application Error alerts"
  type        = string
  default     = ""
}
