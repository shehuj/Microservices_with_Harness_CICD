# Installing a Harness Delegate

## What is a Harness Delegate?

A Harness delegate is a service that runs in your infrastructure and connects to the Harness platform. It executes tasks like:
- Building and deploying applications
- Connecting to your Kubernetes cluster
- Pulling code from GitHub
- Pushing images to Docker registry

## Do You Need a Delegate?

**You MUST have at least one delegate installed** for Harness to execute pipelines.

## Quick Install (Kubernetes)

### Option 1: Install via Harness UI (Recommended)

1. **Navigate to Delegates**:
   - Go to Harness UI > Account Settings > Account Resources > Delegates
   - Click **+ New Delegate**

2. **Choose Kubernetes**:
   - Select **Kubernetes** as the delegate type
   - Click **Continue**

3. **Configure Delegate**:
   - Name: `harness-delegate` (or your preferred name)
   - Size: **Small** (for testing) or **Large** (for production)
   - Tags: Leave empty or add `k8s` if you want to use specific delegate selectors
   - Click **Continue**

4. **Download YAML**:
   - Download the provided `harness-delegate.yaml` file
   - This file contains your account-specific configuration

5. **Install Delegate**:
   ```bash
   # Apply the delegate YAML to your cluster
   kubectl apply -f harness-delegate.yaml

   # Check delegate status
   kubectl get pods -n harness-delegate-ng

   # Watch for delegate to be running
   kubectl logs -f deployment/harness-delegate -n harness-delegate-ng
   ```

6. **Verify in UI**:
   - Return to Harness UI
   - You should see the delegate appear as **Connected** in 2-3 minutes

### Option 2: Install via Helm

```bash
# Add Harness Helm repository
helm repo add harness https://app.harness.io/storage/harness-download/harness-helm-charts/
helm repo update

# Install delegate
helm install harness-delegate harness/harness-delegate-ng \
  --namespace harness-delegate-ng \
  --create-namespace \
  --set delegateName=harness-delegate \
  --set accountId=YOUR_ACCOUNT_ID \
  --set delegateToken=YOUR_DELEGATE_TOKEN \
  --set managerEndpoint=https://app.harness.io/gratis \
  --set replicas=1

# Get your ACCOUNT_ID and DELEGATE_TOKEN from Harness UI:
# Account Settings > Account Resources > Delegates > New Delegate
```

### Option 3: Install via Terraform

Create `harness_delegate.tf`:

```hcl
resource "helm_release" "harness_delegate" {
  name       = "harness-delegate"
  repository = "https://app.harness.io/storage/harness-download/harness-helm-charts/"
  chart      = "harness-delegate-ng"
  namespace  = "harness-delegate-ng"
  create_namespace = true

  set {
    name  = "delegateName"
    value = "harness-delegate"
  }

  set {
    name  = "accountId"
    value = var.harness_account_id
  }

  set {
    name  = "delegateToken"
    value = var.harness_delegate_token
  }

  set {
    name  = "managerEndpoint"
    value = "https://app.harness.io/gratis"
  }

  set {
    name  = "replicas"
    value = 1
  }
}
```

## Delegate Tags/Selectors

### Without Tags (Current Configuration)
The K8s connector is currently configured to use ANY available delegate:
```hcl
delegate_selectors = []
```

This means any delegate in your account can execute tasks.

### With Tags (Specific Delegate)
If you want to use a specific delegate:

1. **Tag your delegate** during installation or in Harness UI:
   - Add tag: `k8s`

2. **Update K8s connector** in `harness_k8s_connector.tf`:
   ```hcl
   delegate_selectors = [var.delegate_selector]
   ```

3. **Re-apply Terraform**:
   ```bash
   terraform apply
   ```

## Troubleshooting

### Delegate Not Connecting

**Check Pod Status**:
```bash
kubectl get pods -n harness-delegate-ng
kubectl describe pod <delegate-pod-name> -n harness-delegate-ng
```

**Check Logs**:
```bash
kubectl logs <delegate-pod-name> -n harness-delegate-ng
```

**Common Issues**:
1. **Wrong Account ID**: Verify `accountId` matches your Harness account
2. **Invalid Token**: Generate a new delegate token in Harness UI
3. **Network Issues**: Ensure cluster can reach `https://app.harness.io`
4. **Resource Limits**: Increase delegate size if pods are crashing

### "No Eligible Delegates" Error

This error means:
1. **No delegate installed** - Install a delegate using steps above
2. **Delegate offline** - Check if delegate pod is running
3. **Selector mismatch** - Either:
   - Remove selectors from connector (use any delegate)
   - OR add matching tags to your delegate

**Quick Fix**:
```bash
# Option 1: Remove selector requirement (already done)
# K8s connector now uses delegate_selectors = []

# Option 2: Tag your existing delegate
# In Harness UI: Delegates > Your Delegate > Edit > Add Tags > "k8s"
```

## Verification

After delegate is installed and connected:

1. **Check Delegate Status in UI**:
   - Account Settings > Account Resources > Delegates
   - Status should be **Connected** (green)

2. **Test Pipeline**:
   ```bash
   # Trigger your CI pipeline
   # It should now execute successfully
   ```

3. **View Delegate Logs**:
   - In Harness UI, click on delegate name
   - View recent task executions

## Delegate Requirements

### Minimum Resources
- **CPU**: 0.5 cores
- **Memory**: 2GB RAM
- **Disk**: 1GB

### Recommended for Production
- **CPU**: 1-2 cores
- **Memory**: 4-8GB RAM
- **Replicas**: 2-3 (for high availability)

### Network Requirements
- Outbound access to `app.harness.io` (port 443)
- Access to your Kubernetes cluster API
- Access to GitHub (for code checkout)
- Access to Docker registry (for image push/pull)

## Next Steps

1. Install delegate using one of the methods above
2. Wait for delegate to show as **Connected** in Harness UI
3. Run `terraform apply` to update K8s connector (if needed)
4. Test your CI/CD pipelines

## Documentation

- [Official Harness Delegate Installation](https://developer.harness.io/docs/platform/delegates/install-delegates/overview)
- [Kubernetes Delegate](https://developer.harness.io/docs/platform/delegates/install-delegates/install-a-kubernetes-delegate)
- [Delegate Tags and Selectors](https://developer.harness.io/docs/platform/delegates/manage-delegates/select-delegates-with-selectors)
