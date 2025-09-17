provider "azurerm" {
  features {}
}

# Authenticate to Azure via Azure CLI (recommended) or env vars
# - Azure CLI: az login ; az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
# - Env vars: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID (for service principal)

# These providers will connect to AKS once it's created
# Configure Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# Configure Helm provider (no nested kubernetes block, no kubernetes_alias)
provider "helm" {
  # Nothing special here — it will automatically use the default kubernetes provider
}
