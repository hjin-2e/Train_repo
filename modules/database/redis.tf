# Redis 복제 그룹 (실제 서버 생성)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "trail-redis-cluster"
  description          = "Redis cluster for trail Ticketing PoC"

  # 엔진 설정
  engine         = "redis"
  engine_version = "7.1"
  port           = 6379

  # 네트워크 및 보안 연결
  subnet_group_name          = var.redis_subnet_group_name
  security_group_ids         = [var.redis_sg_id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth_token

  # 구동 테스트용 간단 아키텍처
  parameter_group_name = "default.redis7.cluster.on"

  node_type                  = "cache.t4g.micro"
  automatic_failover_enabled = true

  num_node_groups         = 2 # 샤드 2개
  replicas_per_node_group = 1 # 샤드당 복제본 1개 (자동 장애조치 활성화를 위해 최소 1개 필수)

  # 실제 아키텍쳐 세팅 (오버스펙)
  # parameter_group_name = "default.redis7.cluster.on"

  # node_type                  = "cache.r7g.large"
  # automatic_failover_enabled = true

  # replicas_per_node_group = 2  # 샤드당 복제본 2개
  # num_node_groups         = 3  # 샤드 3개 (총 9대 생성)
}
