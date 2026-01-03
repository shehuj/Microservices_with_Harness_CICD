# Harness Delegate Provisioning
#
# This deploys a Harness delegate to your Kubernetes cluster with the "k8s" tag
#
# To enable delegate deployment:
# 1. Get delegate token from Harness UI (see DELEGATE_TOKEN_SETUP.md)
# 2. Add to terraform.tfvars: harness_delegate_token = "YOUR_TOKEN"
# 3. Run: terraform apply
#
# To skip delegate deployment:
# Add to terraform.tfvars: deploy_delegate = false

resource "helm_release" "harness_delegate" {
  count = var.deploy_delegate && var.harness_delegate_token != "" ? 1 : 0

  name             = "harness-delegate"
  repository       = "https://app.harness.io/storage/harness-download/harness-helm-charts/"
  chart            = "harness-delegate-ng"
  namespace        = "harness-delegate-ng"
  create_namespace = true
  version          = "1.0.8"

  set {
    name  = "delegateName"
    value = var.delegate_name
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
    name  = "delegateDockerImage"
    value = "harness/delegate:latest"
  }

  set {
    name  = "replicas"
    value = var.delegate_replicas
  }

  set {
    name  = "upgrader.enabled"
    value = "true"
  }

  # CRITICAL: Add the "k8s" tag to the delegate
  set {
    name  = "tags"
    value = var.delegate_selector
  }

  # Resource limits
  set {
    name  = "resources.limits.memory"
    value = "2048Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "resources.requests.memory"
    value = "2048Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "0.5"
  }
}

# Output delegate information
output "delegate_namespace" {
  description = "Namespace where delegate is deployed"
  value       = var.deploy_delegate && var.harness_delegate_token != "" ? helm_release.harness_delegate[0].namespace : "N/A - Delegate not deployed"
  sensitive   = true
}

output "delegate_name" {
  description = "Name of the delegate"
  value       = var.deploy_delegate && var.harness_delegate_token != "" ? var.delegate_name : "N/A - Delegate not deployed"
  sensitive   = true
}

output "delegate_tag" {
  description = "Tag assigned to the delegate"
  value       = var.delegate_selector
}

output "delegate_deployed" {
  description = "Whether delegate was deployed via Terraform"
  value       = var.deploy_delegate && var.harness_delegate_token != ""
  sensitive   = true
}
