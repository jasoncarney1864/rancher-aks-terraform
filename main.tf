#############################################
# Root module: orchestrates networking, AKS, and Rancher install
#############################################

# Networking (VNet, subnets, etc.)
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  resource_group_name  = var.resource_group_name
  vnet_cidr            = var.vnet_cidr
  aks_subnet_cidr      = var.aks_subnet_cidr
  tags                 = var.tags
}

# AKS Cluster
module "aks_cluster" {
  source = "./modules/aks-cluster"

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  resource_group_name  = var.resource_group_name
  cluster_name         = var.aks_cluster_name
  kubernetes_version   = var.kubernetes_version
  node_count           = var.aks_node_count
  node_size            = var.aks_node_size
  subnet_id            = module.networking.aks_subnet_id
  tags                 = var.tags

  depends_on = [module.networking]
}

# Rancher install (via Helm)
module "rancher_install" {
  source = "./modules/rancher-install"

  project_name        = var.project_name
  environment         = var.environment
  rancher_hostname    = var.rancher_server_hostname
  rancher_admin_pass  = var.rancher_admin_password

  # Example inputs you may wire from AKS module outputs:
  # kube_host                   = module.aks_cluster.kube_host
  # kube_client_certificate    = module.aks_cluster.kube_client_certificate
  # kube_client_key            = module.aks_cluster.kube_client_key
  # kube_cluster_ca_certificate= module.aks_cluster.kube_cluster_ca_certificate

  depends_on = [module.aks_cluster]
}