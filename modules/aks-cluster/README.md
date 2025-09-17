# Module: aks-cluster

Purpose:
- Provision an AKS cluster (and optionally node pools) in Azure.
- Output Kubernetes connection details for downstream providers/modules.

Expected inputs (suggested):
- `project_name`, `environment`, `location`, `resource_group_name`
- `cluster_name`, `kubernetes_version`, `node_count`, `node_size`, `subnet_id`, `tags`

Expected outputs (suggested):
- `kubeconfig` (sensitive), or discrete fields:
  - `kube_host`, `kube_client_certificate`, `kube_client_key`, `kube_cluster_ca_certificate`
- Cluster metadata such as `resource_group`, `id`, `identity`, etc.