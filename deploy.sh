#!/bin/bash

# Quick deployment script for Rancher AKS Terraform
# This script automates the deployment process

set -e

echo "🚀 Starting Rancher AKS deployment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install it first."
    exit 1
fi

if ! az account show &> /dev/null; then
    echo "❌ Not logged into Azure. Please run 'az login' first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install it first."
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform.tfvars with your configuration before continuing."
    echo "   Required changes:"
    echo "   - rancher_bootstrap_password: Set a secure password (min 12 chars)"
    echo "   - letsencrypt_email: Set your email address"
    echo ""
    read -p "Press Enter after editing terraform.tfvars to continue..."
fi

# Validate terraform.tfvars
echo "🔍 Validating configuration..."

# Check if email is still the example
if grep -q "your-email@example.com" terraform.tfvars; then
    echo "❌ Please update the letsencrypt_email in terraform.tfvars"
    exit 1
fi

# Check if password is still the example
if grep -q "RancherPassword123!" terraform.tfvars; then
    echo "⚠️  Warning: You're using the example password. Consider changing it for security."
fi

# Initialize Terraform
echo "🏗️  Initializing Terraform..."
terraform init

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

echo ""
echo "📊 Deployment Summary:"
echo "This will create:"
echo "  • Azure Resource Group"
echo "  • AKS Cluster (1 node, auto-scaling enabled)"
echo "  • Load Balancer with public IP"
echo "  • ingress-nginx controller"
echo "  • cert-manager for TLS certificates"
echo "  • Rancher with Let's Encrypt TLS"
echo ""
echo "💰 Estimated cost: ~$55-90/month"
echo ""

read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

# Apply deployment
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

# Get outputs
echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Information:"
terraform output

echo ""
echo "🔧 Next Steps:"
echo "1. Configure kubectl:"
echo "   $(terraform output -raw kubectl_config_command)"
echo ""
echo "2. Wait for Rancher to be ready (may take 5-10 minutes):"
echo "   kubectl get pods -n cattle-system -w"
echo ""
echo "3. Access Rancher UI:"
echo "   $(terraform output -raw rancher_url)"
echo "   Username: admin"
echo "   Password: [your bootstrap password]"
echo ""
echo "4. Verify all pods are running:"
echo "   kubectl get pods --all-namespaces"
echo ""

# Cleanup plan file
rm -f tfplan

echo "🎉 Setup complete! Happy Ranching! 🤠"