resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6" # 필요시 최신 버전으로 변경 가능
  namespace        = "argocd"
  create_namespace = true

  # values 값을 통해 ArgoCD 설치와 동시에 Application (깃허브 연동) 설정을 주입합니다.
  values = [
    yamlencode({
      server = {
        additionalApplications = [
          {
            name      = "${var.project_name}-${var.environment}-app"
            namespace = "argocd"
            project   = "default"
            source = {
              repoURL        = var.gitops_repo_url
              targetRevision = "HEAD"
              # 감시할 폴더 경로 (dev/prod 환경에 따라 동적으로 설정)
              path = "modules/infra/k8s-manifests/overlays/${var.environment}"
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
        ]
      }
    })
  ]
}
