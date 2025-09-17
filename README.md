# Rancher AKS Terraform

A complete infrastructure-as-code solution for deploying Rancher on Azure Kubernetes Service (AKS) with automated TLS certificates and GitHub Codespaces development environment.

## 🚀 Features

- **Complete Development Environment**: GitHub Codespaces with all required tools pre-configured
- **Cost-Optimized AKS**: Single-node cluster with auto-scaling and cost-effective VM sizes
- **Automated TLS**: Let's Encrypt certificates with automatic renewal
- **Wildcard DNS**: Uses sslip.io for DNS without external DNS management
- **Azure Best Practices**: Follows Microsoft Azure naming conventions and security practices
- **One-Click Deploy**: Minimal configuration required to get started

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │      Azure       │    │    Rancher      │
│   Codespaces    │───▶│   AKS Cluster    │───▶│   Management    │
│                 │    │                  │    │                 │
│ • Azure CLI     │    │ • Standard_B2s   │    │ • TLS via       │
│ • Terraform     │    │ • Auto-scaling   │    │   Let's Encrypt │
│ • kubectl       │    │ • LoadBalancer   │    │ • sslip.io DNS  │
│ • Helm          │    │ • RBAC enabled   │    │ • Web UI        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Components Deployed

1. **Azure Resource Group** (`rg-rancher-dev-{random}`)
2. **AKS Cluster** with cost-optimized configuration
3. **ingress-nginx** for external traffic routing
4. **cert-manager** for automatic TLS certificate management
5. **Rancher** with Let's Encrypt TLS certificates

## 💰 Cost Estimation

Estimated monthly cost for the default configuration:

- **AKS Node (Standard_B2s)**: ~$30-60/month
- **Standard Load Balancer**: ~$20/month  
- **Managed Disks**: ~$5-10/month
- **Total**: ~$55-90/month

> **Note**: Costs may vary based on actual usage, region, and Azure pricing changes. Use auto-scaling to optimize costs.

## 🛠️ Prerequisites

1. Azure subscription with sufficient permissions
2. GitHub account (for Codespaces)
3. Valid email address (for Let's Encrypt)

## 🚀 Quick Start

### Option 1: GitHub Codespaces (Recommended)

1. **Open in Codespaces**
   ```bash
   # Click "Code" → "Codespaces" → "Create codespace on main" in GitHub
   # Or use the command palette: Codespaces: Create New Codespace
   ```

2. **Configure Azure credentials**
   ```bash
   az login
   ```

3. **Customize configuration**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

4. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Option 2: Local Development

1. **Install required tools**
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)
   - [Helm](https://helm.sh/docs/intro/install/) (>= 3.0)

2. **Clone and configure**
   ```bash
   git clone https://github.com/jasoncarney1864/rancher-aks-terraform.git
   cd rancher-aks-terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

3. **Deploy**
   ```bash
   az login
   terraform init
   terraform plan
   terraform apply
   ```

## ⚙️ Configuration

Edit `terraform.tfvars` with your specific settings:

```hcl
# Azure and project configuration
location     = "East US"          # Your preferred Azure region
project_name = "rancher"          # Project name for resource naming
environment  = "dev"              # Environment (dev/staging/prod)

# AKS configuration  
node_count     = 1                # Initial number of nodes
max_node_count = 2                # Maximum nodes for auto-scaling
node_vm_size   = "Standard_B2s"   # VM size (cost-optimized)

# Rancher configuration
rancher_bootstrap_password = "YourSecurePassword123!"  # Min 12 characters

# Let's Encrypt configuration
letsencrypt_email = "your-email@example.com"  # Your email for certificates
```

### VM Size Options

| VM Size | vCPU | RAM | Monthly Cost* | Use Case |
|---------|------|-----|---------------|----------|
| Standard_B2s | 2 | 4 GB | ~$30-60 | Development, testing |
| Standard_DS2_v2 | 2 | 7 GB | ~$70-100 | Small production |
| Standard_D2s_v3 | 2 | 8 GB | ~$70-100 | Latest generation |

*Approximate costs, may vary by region

## 🔧 Post-Deployment

After successful deployment, you'll receive output with:

1. **Rancher URL**: `https://{external-ip}.sslip.io`
2. **kubectl configuration command**
3. **Next steps for accessing and configuring Rancher**

### Accessing Rancher

1. **Get the Rancher URL from Terraform output**
   ```bash
   terraform output rancher_url
   ```

2. **Configure kubectl**
   ```bash
   az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)
   ```

3. **Verify deployment**
   ```bash
   kubectl get pods --all-namespaces
   kubectl get pods -n cattle-system
   ```

4. **Access Rancher UI**
   - Open the Rancher URL in your browser
   - Username: `admin`
   - Password: Your bootstrap password from `terraform.tfvars`

## 🔍 Troubleshooting

### Common Issues

1. **Ingress IP not available**
   ```bash
   kubectl get svc -n ingress-nginx
   # Wait for EXTERNAL-IP to be assigned
   ```

2. **Certificate not issued**
   ```bash
   kubectl get certificaterequests -A
   kubectl describe certificaterequest -n cattle-system
   ```

3. **Rancher pods not starting**
   ```bash
   kubectl logs -n cattle-system -l app=rancher
   kubectl describe pods -n cattle-system -l app=rancher
   ```

### Resource Cleanup

To destroy all resources:

```bash
terraform destroy
```

> **Warning**: This will permanently delete all resources and data.

## 📋 Development

### Codespaces Features

The development environment includes:

- **Pre-configured tools**: Azure CLI, Terraform, kubectl, Helm
- **VS Code extensions**: Terraform, Kubernetes, Azure tools
- **Helpful aliases**: `tf`, `k`, `azaks`, etc.
- **Auto-completion**: For all major tools

### Local Development Setup

If using local development, run the post-create script:

```bash
bash .devcontainer/post-create.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: Open a GitHub issue
- **Documentation**: See [Rancher Documentation](https://rancher.com/docs/)
- **Azure AKS**: See [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)

## 🔗 Related Projects

- [Rancher](https://rancher.com/) - Kubernetes management platform
- [cert-manager](https://cert-manager.io/) - Kubernetes certificate management
- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/) - NGINX Ingress Controller
- [sslip.io](https://sslip.io/) - Wildcard DNS for IP addresses
