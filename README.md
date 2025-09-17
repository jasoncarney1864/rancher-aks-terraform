# Rancher AKS Terraform

Terraform project to deploy Rancher on Azure Kubernetes Service (AKS), optimized for GitHub Codespaces development and structured for multi-cloud portability.

## Overview

This project provisions:
- Azure Kubernetes Service (AKS) cluster
- NGINX Ingress Controller
- cert-manager for automatic TLS certificates
- Rancher management platform with Let's Encrypt TLS

The setup uses dynamic IP-based DNS (sslip.io or nip.io) to automatically generate valid hostnames without requiring custom DNS configuration.

## Prerequisites

- Azure subscription with appropriate permissions
- GitHub Codespaces or local development environment with the required tools

## Quick Start with GitHub Codespaces

### Option 1: Automated Quick Start
1. **Open in Codespaces**: Click the "Code" button in GitHub and select "Create codespace on main"
2. **Run the quick start script**:
   ```bash
   ./quick-start.sh
   ```
   This script will guide you through the entire setup process.

### Option 2: Manual Setup
1. **Open in Codespaces**: Click the "Code" button in GitHub and select "Create codespace on main"

2. **Login to Azure**: Once the codespace is ready, authenticate with Azure:
   ```bash
   az login
   ```

3. **Configure Terraform variables**: Copy the example variables file and customize:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your email address for Let's Encrypt
   ```

4. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Access Rancher**: After deployment, get the Rancher URL:
   ```bash
   terraform output rancher_url
   ```

## Configuration Variables

### Required Variables
- `acme_email`: Email address for Let's Encrypt certificate registration

### Optional Variables (with defaults)
- `project_name`: Project name (default: "rancher-aks")
- `environment`: Environment name (default: "dev")
- `location`: Azure region (default: "eastus2")
- `node_vm_size`: VM size for AKS nodes (default: "Standard_B2ms")
- `node_count`: Number of nodes (default: 1)
- `kubernetes_version`: Kubernetes version (default: Azure's latest supported)
- `letsencrypt_environment`: "staging" or "production" (default: "staging")
- `ip_dns_provider`: "sslip.io" or "nip.io" (default: "sslip.io")

## Local Development Setup

If not using GitHub Codespaces, ensure you have these tools installed:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

## Usage Examples

### Basic deployment with staging certificates:
```bash
# terraform.tfvars
acme_email = "admin@example.com"
```

### Production deployment:
```bash
# terraform.tfvars
acme_email = "admin@example.com"
letsencrypt_environment = "production"
project_name = "rancher-prod"
environment = "production"
node_count = 3
node_vm_size = "Standard_D2s_v3"
```

### Using nip.io instead of sslip.io:
```bash
# terraform.tfvars
acme_email = "admin@example.com"
ip_dns_provider = "nip.io"
```

## Post-Deployment

### Configure kubectl
```bash
terraform output kubectl_config_command
# Run the output command to configure kubectl
```

### Access Rancher
1. Get the Rancher URL: `terraform output rancher_url`
2. Open the URL in your browser
3. Follow the Rancher setup wizard

### Initial Rancher Setup
- The first time you access Rancher, you'll need to set an admin password
- The bootstrap password can be retrieved from the Rancher pod if needed

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Troubleshooting

### Certificate Issues
- If using staging certificates, you'll see browser warnings (this is expected)
- For production certificates, ensure your email is valid and you haven't hit Let's Encrypt rate limits

### DNS Resolution
- sslip.io and nip.io provide automatic DNS resolution for any IP
- Format: `<ip-address>.sslip.io` or `<ip-address>.nip.io`
- These services work without additional configuration

### AKS Connection Issues
- Ensure you're logged into Azure: `az login`
- Verify kubectl configuration: `kubectl config current-context`

## Architecture

```
Internet -> Azure Load Balancer (Public IP) -> NGINX Ingress -> Rancher (TLS via Let's Encrypt)
```

- AKS cluster with system-assigned managed identity
- Azure CNI networking with Azure Network Policy
- Auto-scaling node pool (1-3 nodes)
- Standard Load Balancer with static public IP
- cert-manager for automatic TLS certificate management
- NGINX Ingress Controller for traffic routing

## Security Considerations

- Uses Azure managed identity for AKS
- Network policies enabled for pod-to-pod security
- TLS encryption for all web traffic
- Let's Encrypt certificates for trusted TLS
- Minimal resource group permissions required

## Cost Optimization

- Default configuration uses `Standard_B2ms` VMs (2 vCPU, 8GB RAM)
- Single node by default with auto-scaling enabled
- Consider scaling up for production workloads
- Monitor costs in Azure Cost Management
