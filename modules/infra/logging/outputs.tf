# ==================
# ops-logs S3 버킷 outputs
# ==================
output "ops_logs_bucket_id" {
  description = "The name (ID) of the ops-logs S3 bucket"
  value       = var.create_s3_buckets ? aws_s3_bucket.ops_logs[0].id : ""
}

output "ops_logs_bucket_arn" {
  description = "The ARN of the ops-logs S3 bucket"
  value       = var.create_s3_buckets ? aws_s3_bucket.ops_logs[0].arn : ""
}

output "ops_logs_bucket_domain_name" {
  description = "The domain name of the ops-logs S3 bucket"
  value       = var.create_s3_buckets ? aws_s3_bucket.ops_logs[0].bucket_domain_name : ""
}
