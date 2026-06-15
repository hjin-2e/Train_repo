# ==============================================================================
# ⚠️ EKS 클러스터 생성 완료 후 필요 시 주석 해제하여 사용할 것 (RBAC 설정)
# (EKS Addon 및 Service Account는 EKS 모듈 및 K8s Manifest로 각각 이전됨)
# ==============================================================================
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

