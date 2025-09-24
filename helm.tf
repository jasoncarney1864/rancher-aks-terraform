module "ingress_nginx" {
  source           = "./modules/helm_release"
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}

module "cert_manager" {
  source           = "./modules/helm_release"
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  sets = {
    installCRDs = "true"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}