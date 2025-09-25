// Configure the Azure Provider
provider "azurerm" {
  features {}
}

provider "kubernetes" {
  # Use local kubeconfig file to decouple provider init from AKS resource creation
  config_path = coalesce(var.kubeconfig_path, pathexpand("~/.kube/config"))
}

provider "helm" {
  # Helm v3 provider syntax: supply Kubernetes connection as an attribute object
  kubernetes = {
    config_path = coalesce(var.kubeconfig_path, pathexpand("~/.kube/config"))
  }
}
