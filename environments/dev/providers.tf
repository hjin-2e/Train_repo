terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # EKS 생성 후 주석 해제
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">= 3.0.0"
    # }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.0"
    # }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# EKS 생성 후 주석 해제
# provider "kubernetes" {
#   host                   = module.eks-cluster.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
#
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks-cluster.cluster_name]
#   }
# }

# EKS 생성 후 주석 해제
# provider "helm" {
#   kubernetes {
#     host                   = module.eks-cluster.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
#
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args        = ["eks", "get-token", "--cluster-name", module.eks-cluster.cluster_name]
#     }
#   }
# }