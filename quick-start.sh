#!/bin/bash

# Quick start script for Rancher AKS Terraform deployment
# This script helps guide users through the deployment process

set -e

echo "🚀 Rancher AKS Terraform Quick Start"
echo "====================================="

# Check if running in Codespaces
if [ -n "${CODESPACES}" ]; then
    echo "✅ Running in GitHub Codespaces"
else
    echo "⚠️  Not running in GitHub Codespaces. Ensure you have the required tools installed:"
    echo "   - Azure CLI, Terraform, kubectl, Helm"
fi

echo ""

# Check if already logged into Azure
if az account show &>/dev/null; then
    echo "✅ Already logged into Azure"
    SUBSCRIPTION_NAME=$(az account show --query "name" -o tsv)
    echo "   Current subscription: $SUBSCRIPTION_NAME"
else
    echo "🔐 Please login to Azure:"
    echo "   Run: az login"
    echo ""
    read -p "Press Enter after completing Azure login..."
fi

echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Setting up terraform.tfvars..."
    
    # Check if example exists
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        echo "✅ Created terraform.tfvars from example"
        echo ""
        echo "⚠️  IMPORTANT: Please edit terraform.tfvars and set your email address:"
        echo "   - acme_email: Required for Let's Encrypt certificates"
        echo "   - Optionally customize other variables"
        echo ""
        read -p "Press Enter after editing terraform.tfvars..."
    else
        echo "❌ terraform.tfvars.example not found"
        exit 1
    fi
else
    echo "✅ terraform.tfvars already exists"
fi

echo ""

# Check if acme_email is set
if grep -q 'acme_email.*=.*".*@.*"' terraform.tfvars; then
    echo "✅ Email address configured in terraform.tfvars"
else
    echo "❌ Please set a valid email address in terraform.tfvars (acme_email = \"your-email@example.com\")"
    exit 1
fi

echo ""
echo "🏗️  Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning deployment..."
terraform plan

echo ""
echo "🚀 Ready to deploy!"
echo ""
echo "Next steps:"
echo "1. Review the Terraform plan above"
echo "2. Run: terraform apply"
echo "3. After deployment, get the Rancher URL with: terraform output rancher_url"
echo "4. Configure kubectl with: \$(terraform output kubectl_config_command)"
echo ""
echo "For staging certificates, you'll see browser warnings (this is expected)"
echo "To use production certificates, set letsencrypt_environment = \"production\" in terraform.tfvars"