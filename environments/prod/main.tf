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

module "logging" {
  source       = "../../modules/infra/logging"
  project_name = var.project_name
  environment  = var.environment

  log_retention_days = 30 #prod라서 env랑 다르게 수정했어요

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

# ==============================================================================
# Kustomize 환경변수(.env) 자동 생성 (ArgoCD/GitOps 연동용)
# ==============================================================================
resource "local_file" "backend_kustomize_env" {
  filename = "../../modules/infra/k8s-manifests/overlays/${var.environment}/backend-config.env"
  content  = <<-EOT
    # 이 파일은 Terraform에 의해 자동 생성되었습니다. 직접 수정하지 마세요.
    PORT=8080
    ALLOWED_ORIGINS=https://${var.project_name}.cloud,https://www.${var.project_name}.cloud
    AWS_REGION=${var.aws_region}
    
    # SQS 및 DB
    SQS_QUEUE_URL=${module.database.sqs_queue_url}
    DB_HOST=${module.database.aurora_writer_endpoint}
    DB_PORT=3306
    DB_NAME=trail_db
    
    REDIS_HOST=${module.database.redis_primary_endpoint}
    REDIS_PORT=6379
  EOT
}