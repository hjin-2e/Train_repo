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

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
}

module "cognito" {
  source       = "../../modules/infra/cognito"
  project_name = var.project_name
  environment  = var.environment
}

# EKS ÏÉùÏÑ± ÌõÑ Ï£ºÏÑù Ìï¥Ï†ú
# module "alb_controller" {
#   source = "../../modules/infra/alb-controller"
#
#   project_name      = var.project_name
#   environment       = var.environment
#   aws_region        = var.aws_region
#   vpc_id            = module.networking.vpc_id
#
#   cluster_name      = module.eks-cluster.cluster_name
#   oidc_provider_arn = module.eks-cluster.oidc_provider_arn
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
# ==============================================================================
# 2. Logging ∏µ‚ (∞≥πﬂ ∑Œ±◊ S3 πˆ≈∂ + WAF CloudWatch ∑Œ±◊ ±◊∑Ï/º≥¡§)
# ==============================================================================
module "logging" {
  source       = "../../modules/infra/logging"
  project_name = var.project_name
  environment  = var.environment

  # WAF Web ACL ARN: networking ∏µ‚¿Ã ∏’¿˙ ª˝º∫µ» µ⁄ ¡÷¿‘µÀ¥œ¥Ÿ.
  waf_web_acl_arn    = module.networking.waf_arn
  log_retention_days = 7 # dev »Ø∞Ê: 7¿œ ∫∏¡∏

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

# ==============================================================================
# 3. Frontend CI/CD Pipeline ∏µ‚
#    GitHub Actions(CI) °Ê S3 °Ê CodePipeline °Ê CodeBuild(CD) ∆ƒ¿Ã«¡∂Û¿Œ
# ==============================================================================
module "frontend-pipeline" {
  source       = "../../modules/infra/frontend-pipeline"
  project_name = var.project_name
  environment  = var.environment

  # networking ∏µ‚¿Ã ª˝º∫«— «¡∑–∆Æø£µÂ S3 πˆ≈∂∞˙ CloudFront ID∏¶ ¡÷¿‘«’¥œ¥Ÿ.
  frontend_bucket_name       = module.networking.s3_frontend_bucket
  cloudfront_distribution_id = module.networking.cloudfront_distribution_id

  # ?? Ω«¡¶ GitHub ∑π∆˜ ∞Ê∑Œ∑Œ ∫Ø∞Ê«œººø‰ (øπ: "your-org/your-frontend-repo")
  github_repo = "your-org/your-repo"

  # dev »Ø∞Êø°º≠¥¬ OIDC Provider ª˝º∫ (√≥¿Ω «— π¯∏∏)
  create_github_oidc_provider = true
}
