# ==============================================================================
# 1. 인프라 직접 수행하는 VPC 및 서브넷 정보 동적 조회
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

# ==============================================================================
# 2. 루트 도면 설계 (모듈 간 직접 참조를 제거하여 순환 참조 완벽 차단)
# ==============================================================================

module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment

  cloudfront_domain_name = var.cloudfront_domain_name
  cloudfront_zone_id     = var.cloudfront_zone_id
  alb_dns_name           = var.alb_dns_name
  alb_zone_id            = var.alb_zone_id
  eks_cluster_name       = "${var.project_name}-${var.environment}-eks"
  bastion_public_key_path = var.bastion_public_key_path

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private.ids
}

module "cognito" {
  source       = "../../modules/infra/cognito"
  project_name = var.project_name
  environment  = var.environment
}
