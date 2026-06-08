provider "aws" {
  region = "ap-northeast-2"

  #2.x 버전의 AWS 공급자 허용
  version = ">= 5.50, < 6.0"
}

module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "eks-cluster" {
  source        = "../../infra"
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
