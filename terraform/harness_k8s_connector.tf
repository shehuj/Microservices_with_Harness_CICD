resource "harness_platform_connector_kubernetes" "k8s" {
  identifier = var.k8s_connector_id
  name       = "K8s Connector"
  org_id     = var.org_id
  project_id = var.project_id

  inherit_from_delegate {
    delegate_selectors = [var.delegate_selector]
  }
}
