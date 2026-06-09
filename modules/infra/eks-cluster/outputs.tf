output "cluster_name" {
  description = "The name of the EKS cluster"
  value = module.eks-cluster.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API server"
  value       = module.eks-cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster"
  value       = module.eks-cluster.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider associated with the EKS cluster"
  value       = module.eks-cluster.oidc_provider_arn
}

output "oidc_provider" {
  description = "The OIDC Provider URL associated with the EKS cluster"
  value       = module.eks-cluster.oidc_provider
}