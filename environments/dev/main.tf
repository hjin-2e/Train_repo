module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment

  # Route53 루트 이관 및 변수 기본값 적용에 따라 수동 도메인 연동 매핑 제거
  eks_cluster_name = "${var.project_name}-${var.environment}-eks"

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

module "alb_controller" {
  source = "../../modules/infra/alb-controller"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  vpc_id       = module.networking.vpc_id

  cluster_name      = module.eks-cluster.cluster_name
  oidc_provider_arn = module.eks-cluster.oidc_provider_arn

  ops_logs_bucket_id = module.logging.ops_logs_bucket_id
  public_subnet_ids  = module.networking.public_subnet_ids
  alb_sg_id          = module.networking.alb_sg_id
}

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
