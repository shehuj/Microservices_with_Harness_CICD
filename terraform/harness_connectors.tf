resource "harness_platform_connector_github" "github" {
  identifier         = var.github_connector_id
  name               = "GitHub Connector"
  org_id             = var.org_id
  project_id         = var.project_id
  url                = "https://github.com"
  validation_repo    = var.github_repo
  connection_type    = "Account"
  delegate_selectors = ["helm-delegate"]

  credentials {
    http {
      username  = "git"
      token_ref = harness_platform_secret_text.github_pat.identifier
    }
  }
}

resource "harness_platform_connector_docker" "docker_registry" {
  identifier         = var.docker_connector_id
  name               = "Docker Registry Connector"
  org_id             = var.org_id
  project_id         = var.project_id
  type               = "DockerHub"
  url                = var.docker_registry_url
  delegate_selectors = []

  depends_on = [harness_platform_secret_text.docker_registry_password]

  credentials {
    username     = var.docker_username
    password_ref = harness_platform_secret_text.docker_registry_password.identifier
  }
}
