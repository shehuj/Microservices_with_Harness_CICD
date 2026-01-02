resource "harness_platform_connector_github" "github" {
  identifier  = var.github_connector_id
  name        = "GitHub Connector"
  url         = "https://github.com"
  validation_repo = var.github_repo

  api_access {
    spec {
      token_ref = "account.GITHUB_PAT"
    }
  }
}

resource "harness_platform_connector_kubernetes" "k8s" {
  identifier = var.k8s_connector_id
  name       = "K8s Connector"
  inherit_from_delegate {
    delegate_selectors = ["k8s"]
  }
}