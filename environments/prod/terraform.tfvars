# Production environment values

project_name         = "rancher-aks"
environment          = "prod"
location             = "eastus2"
resource_group_name  = "rg-rancher-aks-prod"

vnet_cidr            = "10.20.0.0/16"
aks_subnet_cidr      = "10.20.1.0/24"

aks_cluster_name     = "rancher-aks-prod"
kubernetes_version   = null
aks_node_count       = 3
aks_node_size        = "Standard_DS3_v2"

rancher_server_hostname = "rancher.example.com"
# Set via environment variable or a secure mechanism in CI
rancher_admin_password  = "CHANGE_ME"

tags = {
  env     = "prod"
  project = "rancher-aks"
}