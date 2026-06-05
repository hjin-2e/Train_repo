module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
  environment  = var.environment
}

# 인프라
module "eks-cluster" {
  source        = "../../modules/infra/eks-cluster"
  project_name  = var.project_name
  environment   = var.environment
  developer_ips = var.developer_ips

  depends_on = [module.network]
}