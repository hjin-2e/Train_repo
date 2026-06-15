# 로컬 터미널에서 EKS 쿠버네티스 클러스터와 연결을 동기화하는 명령어
output "eks_kubeconfig_command" {
  description = "로컬 터미널에서 EKS 쿠버네티스 클러스터와 연결을 동기화하는 명령어"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks-cluster.cluster_name}"
}

# Ingress 설정에 필요한 ALB 보안그룹 ID
output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = module.networking.alb_sg_id
}
# Ingress 설정에 필요한 ALB ACM 인증서 ARN
output "acm_alb_certificate_arn" {
  description = "ACM Certificate ARN for ALB"
  value       = module.networking.acm_alb_certificate_arn
}

output "app_tg_arn" {
  value = module.eks-cluster.app_tg_arn
}
output "cloudfront_domain_name" {
  value = module.cdn.cloudfront_domain_name
}
output "github_actions_role_arn" {
  value = module.frontend-pipeline.github_actions_role_arn
}
output "pipeline_artifact_bucket_name" {
  value = module.frontend-pipeline.pipeline_artifact_bucket_name
}

output "github_actions_backend_role_arn" {
  description = "Backend CI/CD 템플릿의 role-to-assume 값으로 사용하세요."
  value       = module.backend-pipeline.github_actions_backend_role_arn
}

# ==================
# Outputs for K8s Addons
# ==================
output "vpc_id" {
  value = module.networking.vpc_id
}
output "cluster_name" {
  value = module.eks-cluster.cluster_name
}
output "oidc_provider_arn" {
  value = module.eks-cluster.oidc_provider_arn
}
output "ops_logs_bucket_id" {
  value = module.logging.ops_logs_bucket_id
}
output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "oidc_provider" {
  value = module.eks-cluster.oidc_provider
}

output "aurora_policy_arn" {
  value = module.networking.aurora_policy_arn
}

output "sqs_policy_arn" {
  value = module.networking.sqs_policy_arn
}

output "elasticache_policy_arn" {
  value = module.networking.elasticache_policy_arn
}

output "secrets_policy_arn" {
  value = module.networking.secrets_policy_arn
}

output "cluster_autoscaler_policy_arn" {
  value = module.eks-cluster.cluster_autoscaler_policy_arn
}

# ==============================================================================
# Database & Event Queue outputs
# ==============================================================================
output "aurora_writer_endpoint" {
  description = "RDS DB host endpoint"
  value       = module.database.aurora_writer_endpoint
}

output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = module.database.redis_primary_endpoint
}

output "sqs_queue_url" {
  description = "AWS SQS Reservation queue URL"
  value       = module.database.sqs_queue_url
}

output "mail_queue_url" {
  description = "AWS SQS Mail queue URL"
  value       = module.database.mail_queue_url
}
