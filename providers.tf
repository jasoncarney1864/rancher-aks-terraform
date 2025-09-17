#############################################
# Terraform settings and providers
#############################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# NOTE:
# Configure these providers after AKS is created (or supply a kubeconfig path).
# For now, they remain unconfigured to allow 'terraform init' to succeed.
#
# Example configuration using AKS module outputs (uncomment and wire once available):
#
# provider "kubernetes" {
#   host                   = module.aks_cluster.kube_host
#   client_certificate     = base64decode(module.aks_cluster.kube_client_certificate)
#   client_key             = base64decode(module.aks_cluster.kube_client_key)
#   cluster_ca_certificate = base64decode(module.aks_cluster.kube_cluster_ca_certificate)
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = module.aks_cluster.kube_host
#     client_certificate     = base64decode(module.aks_cluster.kube_client_certificate)
#     client_key             = base64decode(module.aks_cluster.kube_client_key)
#     cluster_ca_certificate = base64decode(module.aks_cluster.kube_cluster_ca_certificate)
#   }
# }