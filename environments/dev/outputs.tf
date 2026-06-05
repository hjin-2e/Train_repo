# 로컬 터미널에서 EKS 쿠버네티스 클러스터와 연결을 동기화하는 명령어
output "eks_kubeconfig_command" {
  description = "로컬 터미널에서 EKS 쿠버네티스 클러스터와 연결을 동기화하는 명령어"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks-cluster.cluster_name}"
}