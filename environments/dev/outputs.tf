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

# 타겟 그룹 ARN (백엔드 파드 연결용)
output "app_tg_arn" {
  description = "App Target Group ARN for TargetGroupBinding"
  value       = module.eks-cluster.app_tg_arn
}

# 프론트엔드 파이프라인 관련 값
output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = module.frontend-pipeline.github_actions_role_arn
}

output "pipeline_artifact_bucket_name" {
  description = "CodePipeline Artifact S3 Bucket Name"
  value       = module.frontend-pipeline.pipeline_artifact_bucket_name
}

# CloudFront 도메인 (최종 접속용)
output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = module.networking.cloudfront_domain_name
}

