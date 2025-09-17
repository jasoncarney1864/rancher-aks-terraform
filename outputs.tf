# Resource Group information
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# AKS Cluster information
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

# Kubernetes configuration
output "kube_config" {
  description = "Kubernetes configuration for kubectl access"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

# Ingress and networking
output "ingress_ip" {
  description = "External IP address of the ingress controller"
  value       = local.ingress_ip
}

# Rancher access information
output "rancher_url" {
  description = "URL to access Rancher UI"
  value       = "https://${local.rancher_hostname}"
}

output "rancher_hostname" {
  description = "Hostname for Rancher (using sslip.io)"
  value       = local.rancher_hostname
}

# Cost and management information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD (approximate)"
  value = {
    aks_nodes      = "~$30-60/month for Standard_B2s nodes"
    load_balancer  = "~$20/month for Standard Load Balancer"
    storage        = "~$5-10/month for managed disks"
    total_estimate = "~$55-90/month"
    note           = "Costs may vary based on actual usage, region, and Azure pricing changes"
  }
}

# Next steps
output "next_steps" {
  description = "Next steps after deployment"
  value = {
    "1_access_rancher" = "Open ${local.rancher_hostname} in your browser"
    "2_login"          = "Use 'admin' as username and your bootstrap password"
    "3_kubectl_config" = "Run: az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.aks.name}"
    "4_verify_pods"    = "Run: kubectl get pods --all-namespaces"
    "5_rancher_status" = "Run: kubectl get pods -n cattle-system"
  }
}