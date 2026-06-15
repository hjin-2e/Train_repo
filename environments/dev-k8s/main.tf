module "alb_controller" {
  source = "../../modules/infra/alb-controller"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  vpc_id                  = data.terraform_remote_state.infra.outputs.vpc_id
  cluster_name            = data.terraform_remote_state.infra.outputs.cluster_name
  oidc_provider_arn       = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  ops_logs_bucket_id      = data.terraform_remote_state.infra.outputs.ops_logs_bucket_id
  acm_alb_certificate_arn = data.terraform_remote_state.infra.outputs.acm_alb_certificate_arn
  public_subnet_ids       = data.terraform_remote_state.infra.outputs.public_subnet_ids
  alb_sg_id               = data.terraform_remote_state.infra.outputs.alb_sg_id
}

module "argocd" {
  source       = "../../modules/infra/argocd"
  project_name = var.project_name
  environment  = var.environment

  depends_on = [module.alb_controller]
}

module "eks_addons" {
  source = "../../modules/infra/eks-addons"

  project_name           = var.project_name
  environment            = var.environment
  cluster_name           = data.terraform_remote_state.infra.outputs.cluster_name
  oidc_provider_arn      = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  oidc_provider          = data.terraform_remote_state.infra.outputs.oidc_provider
  aurora_policy_arn      = data.terraform_remote_state.infra.outputs.aurora_policy_arn
  sqs_policy_arn         = data.terraform_remote_state.infra.outputs.sqs_policy_arn
  elasticache_policy_arn = data.terraform_remote_state.infra.outputs.elasticache_policy_arn
  secrets_policy_arn     = data.terraform_remote_state.infra.outputs.secrets_policy_arn
  aws_region             = var.aws_region
}

module "monitoring" {
  source = "../../modules/infra/monitoring"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = data.terraform_remote_state.infra.outputs.cluster_name

  depends_on = [module.alb_controller]
}

module "logging" {
  source = "../../modules/infra/logging"

  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = data.terraform_remote_state.infra.outputs.cluster_name
  aws_region         = var.aws_region
  oidc_provider_arn  = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  oidc_provider      = data.terraform_remote_state.infra.outputs.oidc_provider
  create_s3_buckets  = false

  depends_on = [module.alb_controller]
}

