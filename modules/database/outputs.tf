# 백엔드에 넘기기 위한 SQS URL
output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}

# Aurora MySQL 클러스터 엔드포인트 주소
output "aurora_writer_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

# ElastiCache Redis 엔드포인트 주소
output "redis_primary_endpoint" {
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}