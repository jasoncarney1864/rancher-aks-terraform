output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource group name"
}

output "aks_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS cluster name"
}

output "kube_admin_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
  description = "Admin kubeconfig to access the cluster"
}

output "ingress_public_ip" {
  value       = try(data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].ip, null)
  description = "Public IP of the NGINX ingress controller"
}

output "rancher_url" {
  value       = "https://${var.rancher_hostname}"
  description = "URL to access Rancher"
}

output "rancher_bootstrap_password" {
  value       = random_password.rancher_bootstrap.result
  sensitive   = true
  description = "Initial Rancher admin password (username: admin). Change it after first login."
}
