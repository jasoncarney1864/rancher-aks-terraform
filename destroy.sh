#!/bin/bash

# Cleanup script for Rancher AKS Terraform deployment
# This script safely destroys all created resources

set -e

echo "🗑️  Rancher AKS Cleanup Script"
echo ""

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "❌ Terraform not initialized. Nothing to clean up."
    exit 1
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy

echo ""
echo "⚠️  WARNING: This will permanently delete:"
echo "  • AKS Cluster and all workloads"
echo "  • Azure Resource Group and all resources"
echo "  • All data and configurations"
echo "  • TLS certificates"
echo ""
echo "💰 This will stop all charges for these resources."
echo ""

read -p "Are you sure you want to destroy all resources? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo ""
read -p "Type 'destroy' to confirm: " confirm
if [ "$confirm" != "destroy" ]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

# Destroy resources
echo "🗑️  Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ All resources have been destroyed successfully!"
echo "💰 Billing for these resources has stopped."
echo ""
echo "🔧 Cleanup complete:"
echo "  • All Azure resources deleted"
echo "  • Local Terraform state cleaned up"
echo ""
echo "👋 Thanks for using Rancher AKS Terraform!"