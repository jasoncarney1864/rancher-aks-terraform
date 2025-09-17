# Azure and project configuration
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Name of the project - used in resource naming"
  type        = string
  default     = "rancher"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# AKS configuration
variable "node_count" {
  description = "Initial number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "Size of the Virtual Machine for AKS nodes"
  type        = string
  default     = "Standard_B2s"
  validation {
    condition = contains([
      "Standard_B2s",    # 2 vCPU, 4 GB RAM - Low cost
      "Standard_DS2_v2", # 2 vCPU, 7 GB RAM - Balanced
      "Standard_D2s_v3"  # 2 vCPU, 8 GB RAM - Latest generation
    ], var.node_vm_size)
    error_message = "The node_vm_size must be a supported cost-optimized VM size."
  }
}

# Rancher configuration
variable "rancher_bootstrap_password" {
  description = "Bootstrap password for Rancher (min 12 characters)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.rancher_bootstrap_password) >= 12
    error_message = "The bootstrap password must be at least 12 characters long."
  }
}

# Let's Encrypt configuration
variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.letsencrypt_email))
    error_message = "Please provide a valid email address for Let's Encrypt."
  }
}