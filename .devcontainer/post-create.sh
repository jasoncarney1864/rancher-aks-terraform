#!/bin/bash

# Post-create script for Rancher AKS Terraform development environment

echo "🚀 Setting up Rancher AKS Terraform development environment..."

# Ensure Azure CLI is properly installed and updated
echo "📦 Updating Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name aks-preview

# Install additional tools
echo "🛠️ Installing additional tools..."

# Install jq for JSON processing
sudo apt-get update && sudo apt-get install -y jq

# Install yq for YAML processing
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Verify installations
echo "✅ Verifying tool installations..."
echo "Terraform version: $(terraform version)"
echo "Azure CLI version: $(az version --output tsv --query '"azure-cli"')"
echo "kubectl version: $(kubectl version --client --short)"
echo "Helm version: $(helm version --short)"

# Initialize Terraform directory
echo "🏗️ Initializing Terraform workspace..."
if [ ! -f "terraform.tfvars" ]; then
    cp terraform.tfvars.example terraform.tfvars 2>/dev/null || true
fi

# Set up helpful aliases
echo "🔧 Setting up helpful aliases..."
cat >> ~/.bashrc << 'EOF'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfs='terraform show'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'

# Azure aliases
alias azg='az group'
alias azaks='az aks'

EOF

echo "🎉 Development environment setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Configure Azure credentials: az login"
echo "2. Copy terraform.tfvars.example to terraform.tfvars and customize"
echo "3. Initialize Terraform: terraform init"
echo "4. Plan deployment: terraform plan"
echo "5. Deploy infrastructure: terraform apply"
echo ""