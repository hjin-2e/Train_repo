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

  # Secrets Manager용 (kms.tf에서 사용)
  # db_admin_user     = var.db_admin_user
  # db_admin_password = var.db_admin_password
  # aurora_endpoint   = var.aurora_endpoint # prod/variables.tf에 추가 필요

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

# module "database" {
#   source                  = "../../modules/database"
#   project_name            = var.project_name
#   environment             = var.environment
#   db_subnet_group_name    = module.networking.db_subnet_group_name
#   redis_subnet_group_name = module.networking.redis_subnet_group_name
#   dms_subnet_group_name   = module.networking.dms_replication_subnet_group_id
#   dms_sg_id               = module.networking.dms_sg_id
#   aurora_sg_id            = module.networking.aurora_sg_id
#   redis_sg_id             = module.networking.redis_sg_id

#   db_admin_user     = var.db_admin_user
#   db_admin_password = var.db_admin_password
#   azure_db_endpoint = var.azure_db_endpoint
#   azure_db_user     = var.azure_db_user
#   azure_db_password = var.azure_db_password
# }
