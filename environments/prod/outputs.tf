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



# ==================
# Bastion SSM outputs

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