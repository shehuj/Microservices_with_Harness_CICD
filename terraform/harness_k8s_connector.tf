resource "harness_platform_connector_kubernetes" "k8s" {
  identifier = var.k8s_connector_id
  name       = "K8s Connector"
  org_id     = var.org_id
  project_id = var.project_id

  inherit_from_delegate {
    delegate_selectors = []
  }
}

# Note: delegate_selectors is set to empty array to use any available delegate
# If you want to use a specific delegate:
# 1. Install a Harness delegate in your cluster
# 2. Tag it with a selector (e.g., "k8s")
# 3. Update delegate_selectors = [var.delegate_selector]
