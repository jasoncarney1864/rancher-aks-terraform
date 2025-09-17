# Module: rancher-install

Purpose:
- Install Rancher on the AKS cluster using Helm.
- Optionally configure ingress/DNS and TLS.

Expected inputs (suggested):
- Kubernetes connection (either `kubeconfig` or discrete cert fields from AKS)
- `rancher_hostname`, `rancher_admin_pass`, and optional values like `chart_version`, `namespace`, `values`

Expected outputs (suggested):
- `rancher_url`