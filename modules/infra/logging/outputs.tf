# ==================
# ops-logs S3 버킷 outputs
# ==================
output "ops_logs_bucket_id" {
  description = "The name (ID) of the ops-logs S3 bucket"
  value       = aws_s3_bucket.ops_logs.id
}

output "ops_logs_bucket_arn" {
  description = "The ARN of the ops-logs S3 bucket"
  value       = aws_s3_bucket.ops_logs.arn
}

# ==================
# WAF CloudWatch 로그 그룹 outputs
# ==================
output "waf_log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs (us-east-1)"
  value       = aws_cloudwatch_log_group.waf.name
}

output "waf_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for WAF logs (us-east-1)"
  value       = aws_cloudwatch_log_group.waf.arn
}
