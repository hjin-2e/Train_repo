output "sns_topic_arn" {
  description = "ARN of the SNS topic for DB Audit alerts"
  value       = aws_sns_topic.db_audit_alerts.arn
}

output "lambda_function_name" {
  description = "Name of the Slack Webhook Lambda function"
  value       = aws_lambda_function.slack_notifier.function_name
}
