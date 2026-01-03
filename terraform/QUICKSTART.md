# Quick Start Guide

## Current Issue

You're getting this error:
```
Error: There are no eligible delegates available in the account to execute the task.
Delegate(s) don't have selectors [k8s]
```

**Root Cause:** You don't have a Harness delegate installed with the tag "k8s".

## Solution (5 Minutes)

### Step 1: Install Harness Delegate

1. **Go to Harness UI**: https://app.harness.io
2. **Navigate**: Account Settings > Account Resources > Delegates
3. **Click**: "+ New Delegate"
4. **Select**: Kubernetes
5. **Configure**:
   - Name: `harness-delegate`
   - Size: `Small`
   - **Tags: `k8s`** ⚠️ CRITICAL - Must add this tag!
6. **Download** the YAML file
7. **Apply** to your Kubernetes cluster:
   ```bash
   kubectl apply -f harness-delegate.yaml
   ```
8. **Wait** for delegate to show as "Connected" (~2-3 minutes)
   ```bash
   # Check status
   kubectl get pods -n harness-delegate-ng
   ```

### Step 2: Re-run Terraform Apply

Once the delegate shows as "Connected" in Harness UI:

```bash
cd terraform
terraform apply
```

### Step 3: Run Pipelines

Your pipelines should now work!

## Visual Guide

### Adding the "k8s" Tag

When creating the delegate, make sure the Tags field looks like this:

```
Tags: k8s
```

Screenshot locations in Harness UI:
1. Account Settings (gear icon, bottom left)
2. Account Resources > Delegates
3. New Delegate > Kubernetes
4. **In the "Tags" field, type: k8s**

## Troubleshooting

### Delegate Not Showing Up?

**Check Pod Status:**
```bash
kubectl get pods -n harness-delegate-ng
kubectl logs -f deployment/harness-delegate -n harness-delegate-ng
```

**Common Issues:**
- Wrong account ID in YAML
- Network connectivity issues
- Insufficient cluster resources

### Still Getting "No Delegates" Error?

1. **Verify delegate is Connected** in Harness UI
2. **Verify delegate has tag "k8s"**:
   - In UI: Delegates > Your Delegate > Tags section
   - Should show: `k8s`
3. **If tag is missing**, edit the delegate:
   - Click on delegate name
   - Click "Edit"
   - Add tag `k8s`
   - Save

### Alternative: Use Different Tag

If you want to use a different tag (e.g., "production"):

1. **Tag your delegate** with your custom tag
2. **Update terraform.tfvars**:
   ```hcl
   delegate_selector = "production"
   ```
3. **Run terraform apply**

## Complete Documentation

- **Detailed Installation**: See `INSTALL_DELEGATE.md`
- **Provider Bug Workaround**: See `PROVIDER_BUG_WORKAROUND.md`
- **Complete Setup**: See `COMPLETE_SETUP_SOLUTION.md`

## After Delegate is Installed

Once your delegate is running with the "k8s" tag:

✅ Terraform can create/update K8s connector
✅ CI pipelines can build your code
✅ CD pipelines can deploy to Kubernetes
✅ All Harness tasks will execute successfully

**Total Time:** ~5 minutes to install delegate + 2 minutes for it to connect
