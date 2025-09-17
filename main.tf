# Configure Terraform providers
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Rancher AKS Deployment"
    ManagedBy   = "Terraform"
  }
}

# Create Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.project_name}-${var.environment}-${random_string.suffix.result}"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.node_vm_size
    os_disk_size_gb = 30

    # Enable auto-scaling for cost optimization
    enable_auto_scaling = true
    min_count           = 1
    max_count           = var.max_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  # Enable RBAC
  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Rancher AKS Cluster"
    ManagedBy   = "Terraform"
  }
}

# Wait for AKS cluster to be ready
resource "time_sleep" "wait_for_aks" {
  depends_on      = [azurerm_kubernetes_cluster.aks]
  create_duration = "30s"
}

# Create namespace for ingress-nginx
resource "kubernetes_namespace" "ingress_nginx" {
  depends_on = [time_sleep.wait_for_aks]

  metadata {
    name = "ingress-nginx"
  }
}

# Create namespace for cert-manager
resource "kubernetes_namespace" "cert_manager" {
  depends_on = [time_sleep.wait_for_aks]

  metadata {
    name = "cert-manager"
  }
}

# Create namespace for Rancher
resource "kubernetes_namespace" "cattle_system" {
  depends_on = [time_sleep.wait_for_aks]

  metadata {
    name = "cattle-system"
  }
}

# Install ingress-nginx using Helm
resource "helm_release" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = "ingress-nginx"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
}

# Wait for ingress-nginx to get external IP
resource "time_sleep" "wait_for_ingress" {
  depends_on      = [helm_release.ingress_nginx]
  create_duration = "60s"
}

# Get the external IP of the ingress controller
data "kubernetes_service" "ingress_nginx" {
  depends_on = [time_sleep.wait_for_ingress]

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

# Install cert-manager using Helm
resource "helm_release" "cert_manager" {
  depends_on = [kubernetes_namespace.cert_manager]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.2"
  namespace  = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "30s"
}

# Create Let's Encrypt ClusterIssuer
resource "kubernetes_manifest" "letsencrypt_issuer" {
  depends_on = [time_sleep.wait_for_cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }
}

# Install Rancher using Helm
resource "helm_release" "rancher" {
  depends_on = [
    kubernetes_namespace.cattle_system,
    helm_release.ingress_nginx,
    helm_release.cert_manager,
    kubernetes_manifest.letsencrypt_issuer
  ]

  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  version    = "2.7.9"
  namespace  = "cattle-system"

  set {
    name  = "hostname"
    value = local.rancher_hostname
  }

  set {
    name  = "bootstrapPassword"
    value = var.rancher_bootstrap_password
  }

  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }

  set {
    name  = "letsEncrypt.email"
    value = var.letsencrypt_email
  }

  set {
    name  = "letsEncrypt.ingress.class"
    value = "nginx"
  }

  timeout = 600
}

# Local values for computed resources
locals {
  # Get the external IP from the ingress service
  ingress_ip = try(data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip, "")

  # Create the sslip.io hostname using the external IP
  rancher_hostname = "${local.ingress_ip}.sslip.io"
}