# Development environment values

project_name         = "rancher-aks"
environment          = "dev"
location             = "eastus"
resource_group_name  = "rg-rancher-aks-dev"

vnet_cidr            = "10.10.0.0/16"
aks_subnet_cidr      = "10.10.1.0/24"

aks_cluster_name     = "rancher-aks-dev"
kubernetes_version   = null
aks_node_count       = 2
aks_node_size        = "Standard_DS2_v2"

rancher_server_hostname = "rancher-dev.example.com"
# Set via environment variable or a secure mechanism in CI
rancher_admin_password  = "CHANGE_ME"

tags = {
  env     = "dev"
  project = "rancher-aks"
}