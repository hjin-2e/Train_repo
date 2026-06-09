# ==============================================================================
# 1. 루트 도면 설계 (모듈 간 직접 참조를 제거하여 순환 참조 완벽 차단)
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

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  # networking 모듈이 VPC를 생성하므로, output을 직접 참조.
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
}

module "cognito" {
  source       = "../../modules/infra/cognito"
  project_name = var.project_name
  environment  = var.environment
}
