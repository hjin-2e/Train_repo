# ==============================================================================
# 1. ë£¨íŠ¸ ë„ë©´ ì„¤ê³„ (ëª¨ë“ˆ ê°„ ì§ì ‘ ì°¸ì¡°ë¥¼ ì œê±°í•˜ì—¬ ìˆœí™˜ ì°¸ì¡° ì™„ë²½ ì°¨ë‹¨)
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

  # Secrets Managerìš© (kms.tfì—ì„œ ì‚¬ìš©)
  # db_admin_user     = var.db_admin_user
  # db_admin_password = var.db_admin_password
  # aurora_endpoint   = var.aurora_endpoint # prod/variables.tfì— ì¶”ê°€ í•„ìš”

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  # networking ëª¨ë“ˆì´ VPCë¥¼ ìƒì„±í•˜ë¯€ë¡œ, outputì„ ì§ì ‘ ì°¸ì¡°.
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

# ==============================================================================
# 2. Logging ¸ğµâ (¿î¿µ ·Î±× S3 ¹öÅ¶ + WAF CloudWatch ·Î±× ±×·ì/¼³Á¤)
# ==============================================================================
module "logging" {
  source       = "../../modules/infra/logging"
  project_name = var.project_name
  environment  = var.environment

  # WAF Web ACL ARN: networking ¸ğµâÀÌ ¸ÕÀú »ı¼ºµÈ µÚ ÁÖÀÔµË´Ï´Ù.
  waf_web_acl_arn    = module.networking.waf_arn
  log_retention_days = 30 # prod È¯°æ: ±ÔÁ¤ ÁØ¼ö¸¦ À§ÇØ 30ÀÏ º¸Á¸

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

# ==============================================================================
# 3. Frontend CI/CD Pipeline ¸ğµâ
#    GitHub Actions(CI) ¡æ S3 ¡æ CodePipeline ¡æ CodeBuild(CD) ÆÄÀÌÇÁ¶óÀÎ
# ==============================================================================
module "frontend-pipeline" {
  source       = "../../modules/infra/frontend-pipeline"
  project_name = var.project_name
  environment  = var.environment

  # networking ¸ğµâÀÌ »ı¼ºÇÑ ÇÁ·ĞÆ®¿£µå S3 ¹öÅ¶°ú CloudFront ID¸¦ ÁÖÀÔÇÕ´Ï´Ù.
  frontend_bucket_name       = module.networking.s3_frontend_bucket
  cloudfront_distribution_id = module.networking.cloudfront_distribution_id

  # ?? ½ÇÁ¦ GitHub ·¹Æ÷ °æ·Î·Î º¯°æÇÏ¼¼¿ä (¿¹: "your-org/your-frontend-repo")
  github_repo = "your-org/your-repo"

  # prod´Â dev¿Í °°Àº AWS °èÁ¤À» »ç¿ëÇÑ´Ù¸é OIDC Provider°¡ ÀÌ¹Ì Á¸ÀçÇÕ´Ï´Ù.
  # º°µµ °èÁ¤ÀÌ¶ó¸é true·Î º¯°æÇÏ¼¼¿ä.
  create_github_oidc_provider = false
}
