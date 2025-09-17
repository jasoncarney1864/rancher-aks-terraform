variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "rancher-aks"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus2"
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2ms"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster. If not specified, Azure will choose a supported default."
  type        = string
  default     = null
}

variable "acme_email" {
  description = "Email address for ACME/Let's Encrypt certificate registration"
  type        = string
}

variable "letsencrypt_environment" {
  description = "Let's Encrypt environment to use"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.letsencrypt_environment)
    error_message = "The letsencrypt_environment must be either 'staging' or 'production'."
  }
}

variable "ip_dns_provider" {
  description = "Dynamic IP-based DNS provider to use"
  type        = string
  default     = "sslip.io"
  validation {
    condition     = contains(["sslip.io", "nip.io"], var.ip_dns_provider)
    error_message = "The ip_dns_provider must be either 'sslip.io' or 'nip.io'."
  }
}