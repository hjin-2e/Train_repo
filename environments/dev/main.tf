
module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  depends_on = [module.networking]
}

module "cognito" {
  source       = "../../modules/infra/cognito"
  project_name = var.project_name
  environment  = var.environment
}

# module "database" {
#   source                  = "../../modules/database"
#   db_subnet_group_name    = module.network.db_subnet_group_name
#   redis_subnet_group_name = module.network.redis_subnet_group_name
#   dms_subnet_group_name   = module.network.dms_replication_subnet_group_id
#   dms_sg_id               = module.network.dms_sg_id
#   aurora_sg_id            = module.network.aurora_sg_id
#   redis_sg_id             = module.network.redis_sg_id
  
#   db_admin_user           = var.db_admin_user
#   db_admin_password       = var.db_admin_password
#   azure_db_endpoint       = var.azure_db_endpoint
#   azure_db_user           = var.azure_db_user
#   azure_db_password       = var.azure_db_password
# }