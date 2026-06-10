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

