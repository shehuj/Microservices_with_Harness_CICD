# Getting Your Harness Delegate Token

## Overview

Terraform can now automatically provision a Harness delegate to your Kubernetes cluster!

You just need to get a delegate token from Harness first.

## Step 1: Get Delegate Token from Harness UI

### Method 1: Via Delegates Page (Recommended)

1. **Go to Harness**: https://app.harness.io
2. **Navigate**: Account Settings (gear icon) > Account Resources > Delegates
3. **Click**: "Tokens" tab at the top
4. **Click**: "+ New Token" button
5. **Configure**:
   - Name: `terraform-delegate-token`
   - (Optional) Set expiration date
6. **Generate**: Click "Generate Token"
7. **Copy**: Copy the token value (starts with something like `NmFnNXhvSlFXZXJoU2N6...`)

⚠️ **IMPORTANT**: Save this token securely - you won't be able to see it again!

### Method 2: Via API (Advanced)

```bash
curl -X POST 'https://app.harness.io/ng/api/delegate-token-ng' \
  -H 'x-api-key: YOUR_HARNESS_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "terraform-delegate-token",
    "accountIdentifier": "YOUR_ACCOUNT_ID",
    "projectIdentifier": "",
    "orgIdentifier": ""
  }'
```

## Step 2: Add Token to terraform.tfvars

Edit `terraform.tfvars` and replace the placeholder:

```hcl
# Find this line:
harness_delegate_token = "CHANGE_ME_GET_FROM_HARNESS_UI"

# Replace with your actual token:
harness_delegate_token = "NmFnNXhvSlFXZXJoU2N6UHhjYXcuNjk1ODJmY2NlYzVmNTc0YTEwMDM2YjE4..."
```

## Step 3: Configure Kubeconfig (If Needed)

By default, Terraform will use `~/.kube/config`. If your kubeconfig is in a different location:

```hcl
# Add to terraform.tfvars:
kubeconfig_path = "/path/to/your/kubeconfig"
```

Or set the KUBECONFIG environment variable:
```bash
export KUBECONFIG=/path/to/your/kubeconfig
```

## Step 4: Deploy Delegate via Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will:
1. Create all Harness resources (secrets, connectors, pipelines, etc.)
2. Deploy a Harness delegate to your Kubernetes cluster
3. Tag the delegate with "k8s" automatically
4. Configure it with proper resources (2GB RAM, 1 CPU)

## Step 5: Verify Delegate Installation

### Check Kubernetes Pods

```bash
# Check delegate pod status
kubectl get pods -n harness-delegate-ng

# Expected output:
# NAME                                READY   STATUS    RESTARTS   AGE
# harness-delegate-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

### Check Delegate Logs

```bash
kubectl logs -f deployment/harness-delegate -n harness-delegate-ng
```

Look for:
- `Delegate connected successfully`
- `Heartbeat published`

### Check Harness UI

1. Go to: Account Settings > Account Resources > Delegates
2. You should see `harness-delegate` with status **Connected** (green dot)
3. Tags should show: `k8s`

## Customization

You can customize the delegate deployment by editing `terraform.tfvars`:

```hcl
# Change delegate name
delegate_name = "my-custom-delegate"

# Increase replicas for high availability
delegate_replicas = 3

# Change the delegate tag
delegate_selector = "production"
```

**Note**: If you change `delegate_selector`, make sure it matches what the K8s connector expects!

## Troubleshooting

### Token Invalid Error

```
Error: Failed to install delegate: Invalid delegate token
```

**Solution**:
- Verify you copied the entire token (it's long!)
- Make sure no extra spaces or newlines
- Generate a new token if needed

### Kubeconfig Not Found

```
Error: Failed to load kubeconfig
```

**Solution**:
- Verify `kubeconfig_path` in terraform.tfvars
- Or set KUBECONFIG environment variable
- Ensure you have access to the cluster: `kubectl get nodes`

### Delegate Pod Not Starting

```bash
kubectl describe pod <delegate-pod-name> -n harness-delegate-ng
```

Common issues:
- Insufficient cluster resources (need 2GB RAM, 1 CPU)
- Network policy blocking outbound to `app.harness.io`
- ImagePullBackOff - check if cluster can pull from Docker Hub

### Delegate Shows "Disconnected"

1. **Check delegate logs**:
   ```bash
   kubectl logs deployment/harness-delegate -n harness-delegate-ng
   ```

2. **Common causes**:
   - Wrong account ID
   - Invalid or expired token
   - Network connectivity to Harness platform
   - Delegate behind proxy (need proxy configuration)

3. **Fix**:
   - Regenerate token
   - Update `terraform.tfvars`
   - Run `terraform apply` again

## Uninstalling Delegate

To remove the delegate:

```bash
# Via Terraform
terraform destroy -target=helm_release.harness_delegate

# Or via kubectl
kubectl delete namespace harness-delegate-ng
```

## Next Steps

Once delegate is running:

1. ✅ Delegate shows as "Connected" in Harness UI
2. ✅ Has tag "k8s"
3. ✅ Run `terraform apply` to create remaining resources
4. ✅ Create GitHub connector via `CREATE_CONNECTORS_WORKAROUND.sh`
5. ✅ Update CI pipeline to enable code checkout
6. ✅ Run your first pipeline!

## Security Note

⚠️ **Never commit `terraform.tfvars` to git!**

The file contains:
- Harness API key
- Delegate token
- Other sensitive credentials

It's already in `.gitignore`, but double-check before committing.

## Documentation

- [Harness Delegate Tokens](https://developer.harness.io/docs/platform/delegates/delegate-concepts/delegate-tokens/)
- [Delegate Installation](https://developer.harness.io/docs/platform/delegates/install-delegates/overview/)
- [Helm Chart Documentation](https://github.com/harness/delegate-helm-chart)
