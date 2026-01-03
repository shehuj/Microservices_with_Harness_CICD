resource "harness_platform_connector_kubernetes" "k8s" {
  identifier = var.k8s_connector_id
  name       = "K8s Connector"
  org_id     = var.org_id
  project_id = var.project_id

  inherit_from_delegate {
    delegate_selectors = [var.delegate_selector]
  }
}

# IMPORTANT: You must install a Harness delegate with the tag "k8s"
#
# Quick steps:
# 1. Go to Harness UI > Account Settings > Delegates > New Delegate
# 2. Choose Kubernetes delegate
# 3. Name it "harness-delegate" and add tag "k8s"
# 4. Download and apply the YAML to your cluster
# 5. Wait for delegate to show as "Connected" in Harness UI
#
# See INSTALL_DELEGATE.md for detailed instructions
