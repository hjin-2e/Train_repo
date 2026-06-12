
# ==============================================================================
# 1. AWS Load Balancer Controller 전용 IAM 역할 생성
# ==============================================================================
module "lb_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = ">= 5.50, < 6.0"

  role_name                              = "${var.project_name}-${var.environment}-lb-controller-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# ==============================================================================
# 2. Helm을 이용해 EKS 워커 노드 내부에 ALB 컨트롤러 앱 최종 배포
# ==============================================================================
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_role.iam_role_arn
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "replicaCount"
    value = "2"
  }
  set {
    name  = "image.tag"
    value = "v2.7.2"
  }
  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/control-plane"
  }
}
