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

# 2. App Service 배포 (dev: B1 + VNet Integration 없음, VPN Gateway도 없으므로 불필요)
module "azure-app-service" {
  source              = "../../modules/azure-app-service"
  project_name        = var.project_name
  environment         = var.environment
  azure_location      = var.azure_location
  resource_group_name = module.azure-networking.resource_group_name
  sku_name            = "B1"
  # app_subnet_id 미전달 → null(기본값) → VNet Integration 비활성화
}
