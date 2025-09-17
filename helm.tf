# Ingress-NGINX (LoadBalancer)
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        publishService = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# cert-manager (optional, used for Let's Encrypt)
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.14.4"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Random bootstrap password for Rancher (more secure than a static value)
resource "random_password" "rancher_bootstrap" {
  length  = 20
  special = false
}

# Rancher Server
locals {
  rancher_base_values = {
    hostname = var.rancher_hostname
    replicas = var.rancher_replicas
  }

  rancher_le_values = {
    ingress = { tls = { source = "letsEncrypt" } }
    letsEncrypt = {
      email       = var.letsencrypt_email
      environment = var.letsencrypt_environment
    }
  }

  rancher_sensitive_values = {
    bootstrapPassword = random_password.rancher_bootstrap.result
  }
}

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  namespace        = "cattle-system"
  create_namespace = true

  values = compact([
    yamlencode(local.rancher_base_values),
    var.letsencrypt_email == null ? "" : yamlencode(local.rancher_le_values),
    yamlencode(local.rancher_sensitive_values)
  ])

  depends_on = [helm_release.ingress_nginx, helm_release.cert_manager]
}

# Read the ingress controller service to get its public IP
data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx.namespace
  }
  depends_on = [helm_release.ingress_nginx]
}
