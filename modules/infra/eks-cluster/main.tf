# ==============================================================================
# 1. VPC 및 서브넷 정보 동적 참조
# ==============================================================================
data "aws_vpc" "selected" {
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-a", "${var.project_name}-private-c"]
  }
}

data "aws_security_group" "eks" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "${var.project_name}-eks-sg"
  }
}

# ==============================================================================
# 2. AWS EKS 클러스터 빌드
# ==============================================================================
module "eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}-eks"
  cluster_version = "1.34"

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private.ids

  # 조작 및 관리를 위해 현재 테라폼을 실행하는 IAM Identity에 관리자 권한 부여
  enable_cluster_creator_admin_permissions = true

  # HPA + Cluster Autoscaler(CA) 요구사항을 반영한 노드 그룹 세팅
  eks_managed_node_groups = {
    fixed_node_group = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"] 

      # Cluster Autoscaler(CA) 자동 확장 연동 범위 설정
      min_size     = 2  
      max_size     = 8 
      desired_size = 3  

      vpc_security_group_ids = [data.aws_security_group.eks.id]
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