# ==============================================================================
# ⚠️ EKS 클러스터 생성 완료 후 주석 해제할 것
# EKS Addon, RBAC, Service Account는 EKS가 먼저 있어야 적용 가능
# ==============================================================================

# # ==================
# # VPC CNI 설정
# # ==================
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name      = var.eks_cluster_name
#   addon_name        = "vpc-cni"
#   addon_version     = "v1.18.0-eksbuild.1"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# 
#   tags = {
#     Name        = "${var.project_name}-vpc-cni"
#     Environment = var.environment
#   }
# }
# 
# # ==================
# # CoreDNS 설정
# # ==================
# resource "aws_eks_addon" "coredns" {
#   cluster_name      = var.eks_cluster_name
#   addon_name        = "coredns"
#   addon_version     = "v1.11.1-eksbuild.4"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# 
#   tags = {
#     Name        = "${var.project_name}-coredns"
#     Environment = var.environment
#   }
# }
# 
# # ==================
# # kube-proxy 설정
# # ==================
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = var.eks_cluster_name
#   addon_name        = "kube-proxy"
#   addon_version     = "v1.30.0-eksbuild.1"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# 
#   tags = {
#     Name        = "${var.project_name}-kube-proxy"
#     Environment = var.environment
#   }
# }
# 
# # ==================
# # RBAC 설정
# # ==================
# 
# # 개발자 Role (읽기 전용)
# resource "kubernetes_cluster_role" "developer" {
#   metadata {
#     name = "developer-role"
#   }
# 
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services", "endpoints"]
#     verbs      = ["get", "list", "watch"]
#   }
# 
#   rule {
#     api_groups = ["apps"]
#     resources  = ["deployments", "replicasets"]
#     verbs      = ["get", "list", "watch"]
#   }
# }
# 
# # 개발자 ClusterRoleBinding
# resource "kubernetes_cluster_role_binding" "developer" {
#   metadata {
#     name = "developer-role-binding"
#   }
# 
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.developer.metadata[0].name
#   }
# 
#   subject {
#     kind      = "User"
#     name      = "hajin.lee"  # 이하진
#     api_group = "rbac.authorization.k8s.io"
#   }
# 
#   subject {
#     kind      = "User"
#     name      = "hanbi.lee"  # 이한비
#     api_group = "rbac.authorization.k8s.io"
#   }
# 
#   subject {
#     kind      = "User"
#     name      = "jaehyeon.cho" # 조재현
#     api_group = "rbac.authorization.k8s.io"
#   }
# 
#   subject {
#     kind      = "User"
#     name      = "gyeongbo.kang" # 강경보
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
# 
# # ==================
# # IRSA Service Account
# # ==================
#
# # Booking Service Account - EKS 생성 후 주석 해제 (실제 사용)
# resource "kubernetes_service_account" "booking" {
#   metadata {
#     name      = "booking-sa"
#     namespace = "default"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.booking_pod.arn
#     }
#   }
# }
#
# # User Service Account - 서비스 분리 시점에 주석 해제
# resource "kubernetes_service_account" "user" {
#   metadata {
#     name      = "user-sa"
#     namespace = "default"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.user_pod.arn
#     }
#   }
# }
#
# # Payment Service Account - 서비스 분리 시점에 주석 해제
# resource "kubernetes_service_account" "payment" {
#   metadata {
#     name      = "payment-sa"
#     namespace = "default"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.payment_pod.arn
#     }
#   }
# }
