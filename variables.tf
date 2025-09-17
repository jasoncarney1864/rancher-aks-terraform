variable "name_prefix" {
  description = "Prefix used for resource names (e.g., rancher)"
  type        = string
  default     = "rancher"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. If null, latest default will be used."
  type        = string
  default     = null
}

variable "node_count" {
  description = "AKS system node count"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for AKS system node pool"
  type        = string
  default     = "Standard_B2ms"
}

variable "rancher_hostname" {
  description = "Public DNS hostname to access Rancher (must resolve to ingress public IP)"
  type        = string
}

variable "rancher_replicas" {
  description = "Number of Rancher server replicas"
  type        = number
  default     = 1
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt. If set, Rancher will request certificates via Let's Encrypt."
  type        = string
  default     = null
}

variable "letsencrypt_environment" {
  description = "Let's Encrypt environment: staging or production. Used only when letsencrypt_email is set."
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.letsencrypt_environment)
    error_message = "letsencrypt_environment must be 'staging' or 'production'"
  }
}
