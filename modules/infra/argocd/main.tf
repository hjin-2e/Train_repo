resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6" # 필요시 최신 버전으로 변경 가능
  namespace        = "argocd"
  create_namespace = true
}

# ArgoCD Application 리소스를 생성하기 위한 공식 argocd-apps 차트 사용
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "1.4.1" # 최신 1.x 버전
  namespace  = "argocd"

  values = [
    yamlencode({
      applications = {
        main_app = {
          name      = "${var.project_name}-${var.environment}-app"
          namespace = "argocd"
          project   = "default"
          source = {
            repoURL        = var.gitops_repo_url
            targetRevision = "HEAD"
            path           = "modules/infra/k8s-manifests/overlays/${var.environment}"
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "default"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = ["CreateNamespace=true"]
          }
        }
      }
    })
  ]

  depends_on = [helm_release.argocd]
}
