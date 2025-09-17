#############################################
# Input variables
#############################################

variable "project_name" {
  type        = string
  description = "Project or application name used for resource naming."
}

variable "environment" {
  type        = string
  description = "Deployment environment identifier (e.g., dev, prod)."
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment."
}

variable "resource_group_name" {
  type        = string
  description = "Existing or managed resource group name for deployment."
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the VNet."
  default     = "10.0.0.0/16"
}

variable "aks_subnet_cidr" {
  type        = string
  description = "CIDR block for the AKS subnet."
  default     = "10.0.0.0/24"
}

variable "aks_cluster_name" {
  type        = string
  description = "AKS cluster name."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for AKS (optional)."
  default     = null
}

variable "aks_node_count" {
  type        = number
  description = "Default node count for the AKS node pool."
  default     = 2
}

variable "aks_node_size" {
  type        = string
  description = "VM size for AKS nodes."
  default     = "Standard_DS2_v2"
}

variable "rancher_server_hostname" {
  type        = string
  description = "Public DNS name for the Rancher server."
}

variable "rancher_admin_password" {
  type        = string
  description = "Initial admin password for Rancher."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to resources."
  default     = {}
}