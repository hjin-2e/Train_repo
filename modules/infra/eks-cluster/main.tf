# ==============================================================================
# 1. AWS 계정 정보 및 데이터 참조
# ==============================================================================
data "aws_caller_identity" "current" {}

# 필요 시 주석 풀고 사용
# data "aws_vpc" "selected" {
#   tags = {
#     Name = "${var.project_name}-vpc"
#   }
# }

# ==============================================================================
# 2. AWS EKS 클러스터 빌드
# ==============================================================================
module "eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}-eks"
  cluster_version = "1.30"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # IAM Identity에 관리자 권한 부여
  enable_cluster_creator_admin_permissions = true

  # 클러스터 컨트롤 플레인 로깅 활성화
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Access Entry 설정 하드코딩 제거
  access_entries = {
    admin_access = {
      kubernetes_groups = []
      # 여기서 동적으로 현재 계정의 ID를 가져와서 사용
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" 
      
      policy_associations = {
        admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # HPA + Cluster Autoscaler(CA) 요구사항 반영
  eks_managed_node_groups = {
    fixed_node_group = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"] 
      min_size       = 2  
      max_size       = 8 
      desired_size   = 3  

      # 노드 역할 정책
      iam_role_additional_policies = {
        AmazonEKSClusterAutoscalerPolicy    = aws_iam_policy.eks_cluster_autoscaler.arn
        AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
        AmazonEKS_CNI_Policy                = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        CloudWatchAgentServerPolicy         = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${var.project_name}-${var.environment}-eks" = "owned"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
  }
}

# ==============================================================================
# 3. IAM 정책 생성 (Cluster Autoscaler 연동용)
# ==============================================================================
resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name        = "${var.project_name}-${var.environment}-eks-ca-policy"
  description = "IAM policy for EKS Cluster Autoscaler inside Node Group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeLaunchTemplateVersions",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeSubnets",
          "ec2:DescribeAvailabilityZones",
          "ec2:GetInstanceTypesFromInstanceRequirements"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}