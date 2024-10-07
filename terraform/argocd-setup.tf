resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

