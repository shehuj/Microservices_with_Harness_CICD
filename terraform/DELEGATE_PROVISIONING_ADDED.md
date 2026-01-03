# Harness Delegate Terraform Provisioning - ADDED ✅

## What Was Added

I've added automatic Harness delegate provisioning to your Terraform configuration!

## New Files Created

### 1. `harness_delegate.tf`
- **Purpose**: Provisions Harness delegate using Helm
- **What it does**:
  - Deploys delegate to Kubernetes via Helm chart
  - Automatically tags delegate with "k8s"
  - Configures resources (2GB RAM, 1 CPU)
  - Sets up auto-upgrader
  - Supports multiple replicas for HA

### 2. `DELEGATE_TOKEN_SETUP.md`
- **Purpose**: Complete guide for getting delegate token
- **Contents**:
  - Step-by-step token generation
  - Configuration instructions
  - Troubleshooting guide
  - Security best practices

### 3. Updated `provider.tf`
- **Added**:
  - Helm provider (~> 2.12)
  - Kubernetes provider (~> 2.25)
- **Purpose**: Enable Helm chart deployments to Kubernetes

### 4. Updated `variables.tf`
- **New variables**:
  - `harness_delegate_token` - For delegate authentication
  - `delegate_name` - Customizable delegate name
  - `delegate_replicas` - Number of delegate instances
  - `kubeconfig_path` - Path to Kubernetes config

### 5. Updated `terraform.tfvars`
- **Added**:
  - `harness_delegate_token` placeholder with instructions
  - `kubeconfig_path` (optional, defaults to ~/.kube/config)

### 6. Updated `QUICKSTART.md`
- **Added**: Option A (Terraform) and Option B (Manual) for delegate installation
- **Highlights**: Terraform method as recommended approach

## How to Use

### Quick Start (3 Steps)

1. **Get delegate token**:
   ```bash
   # Go to: Harness UI > Account Settings > Delegates > Tokens
   # Click "+ New Token", name it, generate and copy
   ```

2. **Add to terraform.tfvars**:
   ```hcl
   harness_delegate_token = "YOUR_TOKEN_HERE"
   ```

3. **Apply Terraform**:
   ```bash
   terraform init
   terraform apply
   ```

That's it! Delegate will be automatically deployed with the "k8s" tag.

## What Gets Created

When you run `terraform apply`, it will now create:

**Harness Resources (8)**:
- ✅ 2 Secrets (github_pat, docker_registry_password)
- ✅ 1 K8s Connector
- ✅ 2 Pipelines (CI, CD)
- ✅ 1 Service
- ✅ 1 Environment
- ✅ 1 Trigger

**Kubernetes Resources (1)**:
- ✅ 1 Delegate (deployed via Helm to harness-delegate-ng namespace)

**Total: 9 resources automatically provisioned!**

## Benefits

### Before (Manual)
1. Generate delegate token
2. Go to Harness UI
3. Navigate to Delegates
4. Click New Delegate
5. Fill out form
6. Download YAML
7. Apply to cluster
8. Wait and verify

### After (Terraform)
1. Get token
2. Add to terraform.tfvars
3. Run `terraform apply`

**Time Saved**: ~10 minutes per delegate installation!

## Configuration Options

Customize in `terraform.tfvars`:

```hcl
# Change delegate name
delegate_name = "prod-delegate"

# High availability setup
delegate_replicas = 3

# Custom tag
delegate_selector = "production"

# Custom kubeconfig
kubeconfig_path = "/path/to/kubeconfig"
```

## Verification

After `terraform apply`:

```bash
# Check Terraform outputs
terraform output delegate_name
terraform output delegate_tag

# Check Kubernetes
kubectl get pods -n harness-delegate-ng
kubectl logs -f deployment/harness-delegate -n harness-delegate-ng

# Check Harness UI
# Navigate to: Account Settings > Delegates
# Should show: harness-delegate (Connected, tag: k8s)
```

## Next Steps

1. **Get delegate token** from Harness UI (see DELEGATE_TOKEN_SETUP.md)
2. **Add token** to terraform.tfvars
3. **Run terraform apply** - creates everything including delegate
4. **Verify delegate** is connected in Harness UI
5. **Create connectors** via CREATE_CONNECTORS_WORKAROUND.sh
6. **Enable CI codebase** configuration
7. **Run your pipelines!**

## Troubleshooting

See `DELEGATE_TOKEN_SETUP.md` for detailed troubleshooting steps.

Common issues:
- Invalid token → Regenerate in Harness UI
- Kubeconfig not found → Set KUBECONFIG env var or update terraform.tfvars
- Pod not starting → Check cluster resources (need 2GB RAM, 1 CPU)
- Delegate disconnected → Check logs for network/auth issues

## Documentation

- `DELEGATE_TOKEN_SETUP.md` - Token generation and configuration
- `QUICKSTART.md` - Updated with Terraform option
- `INSTALL_DELEGATE.md` - Still available for manual installation
- `harness_delegate.tf` - See inline comments for customization

## Summary

✅ Delegate provisioning now fully automated via Terraform
✅ Just need to get token and add to terraform.tfvars
✅ Automatically tagged with "k8s"
✅ Properly configured resources
✅ Complete documentation provided
✅ Backward compatible (manual installation still works)

Your "No eligible delegates" error will be resolved once you:
1. Get the delegate token
2. Add it to terraform.tfvars
3. Run terraform apply
