#!/bin/bash

# Validation script for Rancher AKS deployment
# This script checks the health of all components

echo "🔍 Rancher AKS Deployment Validation"
echo "======================================"
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl not configured. Run:"
    echo "   $(terraform output -raw kubectl_config_command 2>/dev/null || echo 'terraform output kubectl_config_command')"
    exit 1
fi

echo "✅ kubectl configured successfully"
echo ""

# Check cluster info
echo "📊 Cluster Information:"
kubectl cluster-info
echo ""

# Check node status
echo "🖥️  Node Status:"
kubectl get nodes -o wide
echo ""

# Check ingress-nginx
echo "🌐 Ingress Controller Status:"
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
echo ""

# Check ingress external IP
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$INGRESS_IP" ] && [ "$INGRESS_IP" != "null" ]; then
    echo "✅ Ingress External IP: $INGRESS_IP"
else
    echo "⏳ Waiting for ingress external IP..."
    kubectl get svc -n ingress-nginx ingress-nginx-controller -w &
    WATCH_PID=$!
    sleep 30
    kill $WATCH_PID 2>/dev/null
fi
echo ""

# Check cert-manager
echo "🔒 Cert-Manager Status:"
kubectl get pods -n cert-manager
echo ""

# Check ClusterIssuer
echo "📜 Let's Encrypt ClusterIssuer:"
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod | grep -A 5 "Status:"
echo ""

# Check Rancher
echo "🤠 Rancher Status:"
kubectl get pods -n cattle-system
echo ""

# Check Rancher service
echo "🌐 Rancher Service:"
kubectl get svc -n cattle-system
echo ""

# Check ingress
echo "📍 Ingress Resources:"
kubectl get ingress -A
echo ""

# Check certificates
echo "🔐 TLS Certificates:"
kubectl get certificates -A
kubectl get certificaterequests -A
echo ""

# Get Rancher URL
RANCHER_URL=$(terraform output -raw rancher_url 2>/dev/null)
if [ -n "$RANCHER_URL" ]; then
    echo "🚀 Rancher URL: $RANCHER_URL"
    echo ""
    
    # Test if Rancher is responding
    echo "🔍 Testing Rancher connectivity..."
    if command -v curl &> /dev/null; then
        HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" "$RANCHER_URL" --connect-timeout 10)
        if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "301" ]; then
            echo "✅ Rancher is responding (HTTP $HTTP_STATUS)"
        else
            echo "⚠️  Rancher HTTP status: $HTTP_STATUS (may still be starting up)"
        fi
    else
        echo "ℹ️  curl not available for connectivity test"
    fi
fi

echo ""
echo "🎯 Summary:"
echo "----------"

# Count ready pods
TOTAL_PODS=$(kubectl get pods --all-namespaces --no-headers | wc -l)
READY_PODS=$(kubectl get pods --all-namespaces --no-headers | grep "Running" | wc -l)
echo "📊 Pods: $READY_PODS/$TOTAL_PODS running"

# Check if all Rancher pods are ready
RANCHER_READY=$(kubectl get pods -n cattle-system --no-headers | grep "rancher" | grep "Running" | wc -l)
RANCHER_TOTAL=$(kubectl get pods -n cattle-system --no-headers | grep "rancher" | wc -l)

if [ "$RANCHER_TOTAL" -gt 0 ]; then
    if [ "$RANCHER_READY" -eq "$RANCHER_TOTAL" ]; then
        echo "✅ Rancher: All pods running ($RANCHER_READY/$RANCHER_TOTAL)"
    else
        echo "⏳ Rancher: Some pods still starting ($RANCHER_READY/$RANCHER_TOTAL)"
    fi
else
    echo "❌ Rancher: No pods found"
fi

echo ""
if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$RANCHER_READY" -eq "$RANCHER_TOTAL" ] && [ "$RANCHER_TOTAL" -gt 0 ]; then
    echo "🎉 All systems operational! Rancher is ready to use."
    echo "🌐 Access Rancher at: $RANCHER_URL"
    echo "👤 Username: admin"
    echo "🔑 Password: [your bootstrap password from terraform.tfvars]"
else
    echo "⏳ Some components are still starting up. Please wait a few minutes and run this script again."
    echo "💡 Tip: Watch pod status with: kubectl get pods --all-namespaces -w"
fi

echo ""