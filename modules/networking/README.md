# Module: networking

Purpose:
- Create VNet, subnets (including an AKS subnet), and any required NSGs or route tables.

Expected inputs (suggested):
- `project_name`, `environment`, `location`, `resource_group_name`, `vnet_cidr`, `aks_subnet_cidr`, `tags`

Expected outputs (suggested):
- `vnet_id`, `vnet_name`, `aks_subnet_id`, `aks_subnet_name`