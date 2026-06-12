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



# ==============================================================================
# Bastion outputs (DB & EKS)
# ==============================================================================
output "db_bastion_instance_id" {
  description = "DB Bastion Instance ID for SSM connection"
  value       = module.networking.bastion_instance_id
}

output "eks_bastion_instance_id" {
  description = "EKS Bastion Instance ID for SSM connection"
  value       = module.networking.eks_bastion_instance_id
}

output "db_bastion_ssm_connect_command" {
  description = "Command to connect DB Bastion via SSM"
  value       = "aws ssm start-session --target ${module.networking.bastion_instance_id} --region ap-northeast-2"
}

output "eks_bastion_ssm_connect_command" {
  description = "Command to connect EKS Bastion via SSM"
  value       = "aws ssm start-session --target ${module.networking.eks_bastion_instance_id} --region ap-northeast-2"
}