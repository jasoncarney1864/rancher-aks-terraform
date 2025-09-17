#############################################
# Useful outputs
#############################################

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = var.aks_cluster_name
}

# Uncomment and wire once modules are implemented to expose kube access
# output "kubeconfig" {
#   description = "Kubeconfig content for the AKS cluster."
#   value       = module.aks_cluster.kubeconfig
#   sensitive   = true
# }

# output "rancher_url" {
#   description = "URL of the Rancher server."
#   value       = module.rancher_install.rancher_url
# }