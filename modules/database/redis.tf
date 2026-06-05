# Redis 프라이빗 서브넷 그룹
resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "trail-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# 3. Redis 복제 그룹 (실제 서버 생성)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "trail-redis-cluster"
  description          = "Redis cluster for trail Ticketing PoC"

  # 엔진 설정
  engine         = "redis"
  engine_version = "7.1"
  port           = 6379

  # 네트워크 및 보안 연결
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids         = [var.redis_sg_id]
  at_rest_encryption_enabled = true

  # 구동 테스트용 간단 아키텍처
  parameter_group_name = "default.redis7"

  node_type                  = "cache.t4g.micro"
  automatic_failover_enabled = false
  num_cache_clusters         = 1

  # 실제 아키텍쳐 세팅 (오버스펙)
  # parameter_group_name = "default.redis7.cluster.on"

  # node_type                  = "cache.r7g.large"
  # automatic_failover_enabled = true

  # cluster_mode {
  #   replicas_per_node_group = 2  # 샤드당 복제본 2개
  #   num_node_groups         = 3  # 샤드 3개 (총 9대 생성)
  # }
}
