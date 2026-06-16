# ==============================================================================
# EKS Addons
# ==============================================================================

# VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-vpc-cni"
    Environment = var.environment
  }
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-coredns"
    Environment = var.environment
  }
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name        = "${var.project_name}-kube-proxy"
    Environment = var.environment
  }
}


# ==============================================================================
# RBAC Settings
# ==============================================================================

# 개발자 Role (읽기 전용)
resource "kubernetes_cluster_role" "developer" {
  metadata {
    name = "developer-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }
}

# 개발자 ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "developer" {
  metadata {
    name = "developer-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "hajin.lee" # 이하진
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "User"
    name      = "hanbi.lee" # 이한비
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "User"
    name      = "jaehyeon.cho" # 조재현
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "User"
    name      = "gyeongbo.kang" # 강경보
    api_group = "rbac.authorization.k8s.io"
  }
}


# ==============================================================================
# IRSA Roles & Service Accounts
# ==============================================================================

# 1. Booking Service Pod
resource "aws_iam_role" "booking_pod" {
  name = "${var.project_name}-${var.environment}-booking-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:default:booking-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-booking-pod-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "booking_aurora" {
  policy_arn = var.aurora_policy_arn
  role       = aws_iam_role.booking_pod.name
}

resource "aws_iam_role_policy_attachment" "booking_sqs" {
  policy_arn = var.sqs_policy_arn
  role       = aws_iam_role.booking_pod.name
}

resource "aws_iam_role_policy_attachment" "booking_elasticache" {
  policy_arn = var.elasticache_policy_arn
  role       = aws_iam_role.booking_pod.name
}

resource "aws_iam_role_policy_attachment" "booking_secrets" {
  policy_arn = var.secrets_policy_arn
  role       = aws_iam_role.booking_pod.name
}

resource "kubernetes_service_account" "booking" {
  metadata {
    name      = "booking-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.booking_pod.arn
    }
  }
}


# 2. User Service Pod
resource "aws_iam_role" "user_pod" {
  name = "${var.project_name}-${var.environment}-user-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:default:user-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-user-pod-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "user_aurora" {
  policy_arn = var.aurora_policy_arn
  role       = aws_iam_role.user_pod.name
}

resource "kubernetes_service_account" "user" {
  metadata {
    name      = "user-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.user_pod.arn
    }
  }
}


# 3. Payment Service Pod
resource "aws_iam_role" "payment_pod" {
  name = "${var.project_name}-${var.environment}-payment-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:default:payment-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-payment-pod-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "payment_aurora" {
  policy_arn = var.aurora_policy_arn
  role       = aws_iam_role.payment_pod.name
}

resource "aws_iam_role_policy_attachment" "payment_sqs" {
  policy_arn = var.sqs_policy_arn
  role       = aws_iam_role.payment_pod.name
}

resource "kubernetes_service_account" "payment" {
  metadata {
    name      = "payment-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.payment_pod.arn
    }
  }
}

# ==============================================================================
# Helm Releases for KEDA and External-Secrets
# ==============================================================================
# KEDA Operator용 IAM Role (IRSA)
resource "aws_iam_role" "keda_operator" {
  name = "${var.project_name}-${var.environment}-keda-operator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:keda:keda-operator"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-keda-operator-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "keda_sqs" {
  policy_arn = var.sqs_policy_arn
  role       = aws_iam_role.keda_operator.name
}

resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.keda_operator.arn
  }
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
}

data "aws_caller_identity" "current" {}

# ==============================================================================
# Cluster Autoscaler
# ==============================================================================
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.project_name}-${var.environment}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_provider) = "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-cluster-autoscaler-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = var.cluster_autoscaler_policy_arn
  role       = aws_iam_role.cluster_autoscaler.name
}

resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = "kube-system"
  create_namespace = false

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }
}
