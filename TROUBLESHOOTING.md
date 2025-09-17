# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the Rancher AKS deployment.

## 🔍 Quick Diagnostics

Run the validation script to get an overview:
```bash
./validate.sh
```

## Common Issues

### 1. Ingress Controller Not Getting External IP

**Symptoms:**
- `kubectl get svc -n ingress-nginx` shows `<pending>` for EXTERNAL-IP

**Diagnosis:**
```bash
kubectl get events -n ingress-nginx --sort-by='.lastTimestamp'
kubectl describe svc -n ingress-nginx ingress-nginx-controller
```

**Solutions:**
- Wait 5-10 minutes for Azure to provision the Load Balancer
- Check Azure portal for Load Balancer creation status
- Verify AKS cluster has proper permissions

### 2. Let's Encrypt Certificate Not Issued

**Symptoms:**
- Rancher shows certificate warnings
- `kubectl get certificates -A` shows certificates in `False` state

**Diagnosis:**
```bash
kubectl get certificaterequests -A
kubectl describe certificaterequest -n cattle-system
kubectl get challenges -A
kubectl describe challenge -n cattle-system
```

**Solutions:**
- Ensure external IP is accessible from the internet
- Verify DNS resolution: `nslookup <external-ip>.sslip.io`
- Check cert-manager logs: `kubectl logs -n cert-manager -l app=cert-manager`
- Verify ClusterIssuer: `kubectl describe clusterissuer letsencrypt-prod`

### 3. Rancher Pods Not Starting

**Symptoms:**
- Rancher pods stuck in `Pending`, `CrashLoopBackOff`, or `Error` state

**Diagnosis:**
```bash
kubectl get pods -n cattle-system
kubectl describe pod -n cattle-system -l app=rancher
kubectl logs -n cattle-system -l app=rancher
```

**Solutions:**
- Check resource requests vs available resources
- Verify all dependencies (ingress-nginx, cert-manager) are running
- Check for sufficient cluster resources
- Verify bootstrap password meets requirements (min 12 chars)

### 4. Can't Access Rancher UI

**Symptoms:**
- Browser shows "This site can't be reached" or timeout errors

**Diagnosis:**
```bash
# Check if ingress is configured
kubectl get ingress -A

# Test external connectivity
curl -k https://<external-ip>.sslip.io

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

**Solutions:**
- Verify external IP is assigned and accessible
- Check firewall rules (Azure NSG)
- Ensure sslip.io resolves correctly
- Try accessing via IP directly: `https://<external-ip>`

### 5. DNS Resolution Issues

**Symptoms:**
- `<external-ip>.sslip.io` doesn't resolve to the correct IP

**Diagnosis:**
```bash
# Test DNS resolution
nslookup $(terraform output -raw rancher_hostname)
dig $(terraform output -raw rancher_hostname)

# Check external IP
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

**Solutions:**
- Wait a few minutes for DNS propagation
- Try different DNS servers (8.8.8.8, 1.1.1.1)
- Use IP address directly as workaround
- Check if corporate firewall blocks sslip.io

## 🔧 Advanced Debugging

### Check All Component Status
```bash
# Overall cluster health
kubectl get componentstatuses

# All pods across namespaces
kubectl get pods --all-namespaces -o wide

# All services
kubectl get svc --all-namespaces

# All ingress resources
kubectl get ingress --all-namespaces

# Events sorted by time
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Resource Usage
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods --all-namespaces

# Describe nodes to see resource allocation
kubectl describe nodes
```

### Network Connectivity
```bash
# Test internal DNS
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Test external connectivity
kubectl run test-external --image=busybox --rm -it --restart=Never -- wget -qO- http://httpbin.org/ip
```

## 🚑 Recovery Procedures

### Restart Failed Components

**Restart ingress-nginx:**
```bash
kubectl rollout restart deployment -n ingress-nginx ingress-nginx-controller
```

**Restart cert-manager:**
```bash
kubectl rollout restart deployment -n cert-manager cert-manager
kubectl rollout restart deployment -n cert-manager cert-manager-webhook
kubectl rollout restart deployment -n cert-manager cert-manager-cainjector
```

**Restart Rancher:**
```bash
kubectl rollout restart deployment -n cattle-system rancher
```

### Force Certificate Renewal
```bash
# Delete certificate to force renewal
kubectl delete certificate -n cattle-system tls-rancher-ingress

# Delete certificate request
kubectl delete certificaterequest -n cattle-system --all
```

### Reset Helm Releases
```bash
# Check Helm releases
helm list --all-namespaces

# Restart specific release
helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
helm upgrade cert-manager jetstack/cert-manager -n cert-manager --set installCRDs=true
helm upgrade rancher rancher-latest/rancher -n cattle-system
```

## 📊 Monitoring Commands

### Watch Resources
```bash
# Watch pod status
kubectl get pods --all-namespaces -w

# Watch ingress external IP assignment
kubectl get svc -n ingress-nginx -w

# Watch certificate issuance
kubectl get certificates -A -w
```

### Log Monitoring
```bash
# Follow ingress logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f

# Follow cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager -f

# Follow Rancher logs
kubectl logs -n cattle-system -l app=rancher -f
```

## 🆘 Getting Help

If you're still experiencing issues:

1. **Run the validation script** and share the output
2. **Collect logs** from failing components
3. **Check Azure portal** for any service health issues
4. **Review Terraform outputs** for configuration details
5. **Open an issue** with detailed error messages and logs

### Useful Information to Collect
```bash
# Terraform outputs
terraform output

# Cluster information
kubectl cluster-info dump

# All pod descriptions
kubectl describe pods --all-namespaces > pod-descriptions.txt

# All events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' > events.txt
```

## 💡 Prevention Tips

- **Always validate** configuration before applying
- **Monitor resource usage** to prevent resource exhaustion
- **Keep backups** of working terraform.tfvars
- **Test in development** before production deployment
- **Use monitoring** tools for proactive issue detection