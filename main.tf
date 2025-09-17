resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  name = "${var.name_prefix}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = var.tags
}

resource "random_password" "rancher_bootstrap" {
  length  = 20
  special = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.name}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.name

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name                = "system"
    vm_size             = var.node_vm_size
    node_count          = var.node_count
    os_sku              = "Ubuntu"
    only_critical_addons_enabled = false
  auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 2
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  role_based_access_control_enabled = true
  local_account_disabled            = false

  tags = var.tags
}
