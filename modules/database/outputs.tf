# 백엔드에 넘기기 위한 SQS URL
output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue (used by notification module Lambda trigger)"
  value       = aws_sqs_queue.queue.arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue (used by notification module CloudWatch metric)"
  value       = aws_sqs_queue.queue.name
}

# Aurora MySQL 클러스터 엔드포인트 주소
output "aurora_writer_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

# ElastiCache Redis 엔드포인트 주소
output "redis_primary_endpoint" {
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

# Secrets Manager Secret ARN
output "db_secret_arn" {
  description = "ARN of the DB Secrets Manager secret"
  value       = aws_secretsmanager_secret.db.arn
}