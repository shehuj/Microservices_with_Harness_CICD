resource "harness_platform_connector_github" "github" {
  identifier      = var.github_connector_id
  name            = "GitHub Connector"
  org_id          = var.org_id
  project_id      = var.project_id
  url             = "https://github.com"
  validation_repo = var.github_repo

  api_access {
    spec {
      token_ref = "${var.org_id}.${var.project_id}.${harness_platform_encrypted_text.github_pat.identifier}"
    }
  }
}

resource "harness_platform_connector_kubernetes" "k8s" {
  identifier = var.k8s_connector_id
  name       = "K8s Connector"
  org_id     = var.org_id
  project_id = var.project_id

  inherit_from_delegate {
    delegate_selectors = [var.delegate_selector]
  }
}