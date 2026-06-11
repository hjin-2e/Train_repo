module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
  cloudfront_domain_name = var.cloudfront_domain_name
  cloudfront_zone_id     = var.cloudfront_zone_id
  alb_zone_id            = var.alb_zone_id
  eks_cluster_name       = "${var.project_name}-${var.environment}-eks"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "logging" {
  source       = "../../modules/infra/logging"
  project_name = var.project_name
  environment  = var.environment

  log_retention_days = 7

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_subnet_ids
  public_subnet_ids       = module.networking.public_subnet_ids
  alb_sg_id               = module.networking.alb_sg_id
  acm_alb_certificate_arn = module.networking.acm_alb_certificate_arn
  ops_logs_bucket_id      = module.logging.ops_logs_bucket_id

  depends_on = [module.logging]
}

module "cognito" {
  source       = "../../modules/infra/cognito"
  project_name = var.project_name
  environment  = var.environment
}

# EKS 생성 후 주석 해제
# module "alb_controller" {
#   source       = "../../modules/infra/alb-controller"
#
#   project_name            = var.project_name
#   environment             = var.environment
#   aws_region              = var.aws_region
#   vpc_id                  = module.networking.vpc_id
#   cluster_name            = module.eks-cluster.cluster_name
#   oidc_provider_arn       = module.eks-cluster.oidc_provider_arn
#   ops_logs_bucket_id      = module.logging.ops_logs_bucket_id      # 추가
#   acm_alb_certificate_arn = module.networking.acm_alb_certificate_arn  # 추가
#   public_subnet_ids       = module.networking.public_subnet_ids    # 추가
#   alb_sg_id               = module.networking.alb_sg_id            # 추가
# }

module "database" {
  source       = "../../modules/database"
  project_name = var.project_name
  environment  = var.environment

  db_subnet_group_name    = module.networking.db_subnet_group_name
  redis_subnet_group_name = module.networking.redis_subnet_group_name
  dms_subnet_group_name   = module.networking.dms_replication_subnet_group_id
  dms_sg_id               = module.networking.dms_sg_id
  aurora_sg_id            = module.networking.aurora_sg_id
  redis_sg_id             = module.networking.redis_sg_id

  db_admin_user     = var.db_admin_user
  db_admin_password = var.db_admin_password
  azure_db_endpoint = var.azure_db_endpoint
  azure_db_user     = var.azure_db_user
  azure_db_password = var.azure_db_password
}

module "frontend-pipeline" {
  source       = "../../modules/infra/frontend-pipeline"
  project_name = var.project_name
  environment  = var.environment

  frontend_bucket_name       = module.networking.s3_frontend_bucket
  cloudfront_distribution_id = module.networking.cloudfront_distribution_id

  github_repo = "your-org/your-repo"

  create_github_oidc_provider = true
}