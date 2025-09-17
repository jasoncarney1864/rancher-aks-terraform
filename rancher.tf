# Create namespace for Rancher
resource "kubernetes_namespace" "rancher_system" {
  metadata {
    name = "rancher-system"
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}

# Create namespace for cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}

# Add Jetstack Helm repository for cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.1"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = kubernetes_namespace.cert_manager.metadata[0].name
  }

  depends_on = [kubernetes_namespace.cert_manager]
}

# Create ClusterIssuer for Let's Encrypt
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-${var.letsencrypt_environment}"
    }
    spec = {
      acme = {
        server = var.letsencrypt_environment == "production" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-${var.letsencrypt_environment}-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

# Add Rancher Helm repository and install Rancher
resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  version    = "2.7.9"
  namespace  = kubernetes_namespace.rancher_system.metadata[0].name

  set {
    name  = "hostname"
    value = "${azurerm_public_ip.main.ip_address}.${var.ip_dns_provider}"
  }

  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }

  set {
    name  = "letsEncrypt.email"
    value = var.acme_email
  }

  set {
    name  = "letsEncrypt.environment"
    value = var.letsencrypt_environment
  }

  set {
    name  = "letsEncrypt.ingress.class"
    value = "nginx"
  }

  # Wait for cert-manager to be ready
  depends_on = [
    kubernetes_namespace.rancher_system,
    kubernetes_manifest.cluster_issuer,
    helm_release.nginx_ingress
  ]
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.3"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.main.ip_address
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = azurerm_kubernetes_cluster.main.node_resource_group
  }

  depends_on = [azurerm_public_ip.main]
}