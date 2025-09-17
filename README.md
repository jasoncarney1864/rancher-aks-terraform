# Rancher on AKS with Terraform

This Terraform configuration provisions an Azure Kubernetes Service (AKS) cluster and deploys Rancher Server into the cluster using Helm. It also installs NGINX Ingress and cert-manager (optional) to enable HTTPS via Let's Encrypt.

## Prerequisites
- Azure subscription with permissions to create AKS and resource groups
- Azure CLI logged in: `az login` and selected subscription
- Terraform >= 1.5
- DNS hostname you control for Rancher (e.g., `rancher.example.com`)

## What this deploys
- Resource group and AKS cluster (SystemAssigned managed identity)
- NGINX Ingress controller (LoadBalancer)
- cert-manager (CRDs installed)
- Rancher Server with a random bootstrap admin password (output as sensitive)

## Quick start
1) Configure variables:
	- Copy `terraform.tfvars.example` to `terraform.tfvars` and update values, especially:
	  - `rancher_hostname` = your DNS name
	  - Optionally set `letsencrypt_email` to enable automatic HTTPS (staging or production)

2) Initialize and validate:
	```powershell
	terraform init -upgrade
	terraform validate
	```

3) Plan and apply:
	```powershell
	terraform plan
	terraform apply -auto-approve
	```

4) Point DNS to ingress public IP:
	- After apply, check output `ingress_public_ip`
	- Create an A record for `rancher_hostname` pointing to that IP

5) Access Rancher:
	- URL: output `rancher_url`
	- Username: `admin`
	- Password: output `rancher_bootstrap_password` (sensitive)
	- Change the admin password on first login

## Variables
See `variables.tf` and `terraform.tfvars.example` for descriptions and defaults.

## Notes
- Helm provider connects using AKS admin kubeconfig from the newly created cluster.
- If you enable Let's Encrypt, start with `staging` while DNS propagates, then switch to `production`.
- You can customize node size/count via variables.

## Cleanup
```powershell
terraform destroy -auto-approve
```
