# 1. 가상 네트워크 및 서브넷/DNS 인프라 구축
module "azure-networking" {
  source             = "../../modules/azure-networking"
  project_name       = var.project_name
  environment        = var.environment
  azure_location     = var.azure_location
  azure_vnet_cidr    = var.azure_vnet_cidr
  
  # 개발 환경에서는 비용 및 배포 시간 절약을 위해 VPN Gateway 비활성화
  enable_vpn_gateway = false 
}

# 2. App Service 및 가상 네트워크(VNet) 통합 배포
module "azure-app-service" {
  source              = "../../modules/azure-app-service"
  project_name        = var.project_name
  environment         = var.environment
  azure_location      = var.azure_location
  resource_group_name = module.azure-networking.resource_group_name
  app_subnet_id       = module.azure-networking.app_subnet_id

# 3. Azure MySQL Flexible Server (DR Passive DB)
module "azure-database" {
  source                    = "../../modules/azure-database"
  project_name              = var.project_name
  environment               = var.environment
  azure_location            = var.azure_location
  resource_group_name       = module.azure-networking.resource_group_name
  mysql_subnet_id           = module.azure-networking.mysql_subnet_id
  mysql_private_dns_zone_id = module.azure-networking.mysql_private_dns_zone_id
  db_user                   = var.azure_db_user
  db_password               = var.azure_db_password
}

  # DB 연결 정보 (App Service 환경변수로 주입)
  db_host             = module.azure-database.mysql_server_fqdn
  db_port             = "3306"
  db_user             = var.azure_db_user
  db_password         = var.azure_db_password
  db_name             = module.azure-database.mysql_database_name
}
