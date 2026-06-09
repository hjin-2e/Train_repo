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

# 키 페어
# output "bastion_private_key" {
#   description = "The private key data for Bastion host ssh access"
#   value       = module.networking.bastion_private_key
#   sensitive   = true
# }