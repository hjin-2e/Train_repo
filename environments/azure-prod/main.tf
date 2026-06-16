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

# 2. App Service 및 가상 네트워크(VNet) 통합 배포
module "azure-app-service" {
  source              = "../../modules/azure-app-service"
  project_name        = var.project_name
  environment         = var.environment
  azure_location      = var.azure_location
  resource_group_name = module.azure-networking.resource_group_name
  app_subnet_id       = module.azure-networking.app_subnet_id
}
