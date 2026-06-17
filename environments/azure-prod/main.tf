data "terraform_remote_state" "aws_prod" {
  backend = "local"
  config = {
    path = "../prod/terraform.tfstate"
  }
}

# 1. 가상 네트워크, VPN Gateway 및 Local Network Gateway (AWS 연동) 생성
module "azure-networking" {
  source                        = "../../modules/azure-networking"
  project_name                  = var.project_name
  environment                   = var.environment
  azure_location                = var.azure_location
  azure_vnet_cidr               = var.azure_vnet_cidr
  
  # AWS에서 제공된 VPN 터널 정보 전달 (S2S IPsec 연결 활성화)
  aws_vpc_cidr                  = var.aws_vpc_cidr
  aws_vpn_tunnel1_address       = try(data.terraform_remote_state.aws_prod.outputs.vpn_tunnel1_address, "")
  aws_vpn_tunnel1_preshared_key = try(data.terraform_remote_state.aws_prod.outputs.vpn_tunnel1_preshared_key, "")
  aws_vpn_tunnel2_address       = try(data.terraform_remote_state.aws_prod.outputs.vpn_tunnel2_address, "")
  aws_vpn_tunnel2_preshared_key = try(data.terraform_remote_state.aws_prod.outputs.vpn_tunnel2_preshared_key, "")

  enable_vpn_gateway            = true
}

# 2. Azure MySQL Flexible Server (DR Passive DB)
# DMS가 S2S VPN 터널을 통해 Aurora → 이 서버로 full-load-and-cdc 복제 수행
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

  # VNet과 Private DNS Zone 링크가 완전히 생성된 후 MySQL 서버를 만들어야 에러가 나지 않음
  depends_on = [module.azure-networking]
}

# 3. App Service 및 가상 네트워크(VNet) 통합 배포
module "azure-app-service" {
  source              = "../../modules/azure-app-service"
  project_name        = var.project_name
  environment         = var.environment
  azure_location      = var.azure_location
  resource_group_name = module.azure-networking.resource_group_name
  app_subnet_id       = module.azure-networking.app_subnet_id

  # DB 연결 정보 (App Service 환경변수로 주입)
  db_host             = module.azure-database.mysql_server_fqdn
  db_port             = "3306"
  db_user             = var.azure_db_user
  db_password         = var.azure_db_password
  db_name             = module.azure-database.mysql_database_name
}
