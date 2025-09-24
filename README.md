# rancher-aks-terraform
Terraform IaC for deploying a Rancher‑managed Kubernetes cluster on Azure Kubernetes Service (AKS). 
Includes step‑by‑step validation and teardown instructions.

Break it into clear, client‑friendly sections:
- Overview → What this project does (Rancher on AKS via Terraform).
- Prerequisites → Azure CLI, Terraform, Helm, kubectl.
- Deployment Steps → The exact commands we mapped out (terraform init/plan/apply, az aks get-credentials, helm install rancher).
- Validation → kubectl get nodes, kubectl -n cattle-system get pods.
- Teardown → terraform destroy.
