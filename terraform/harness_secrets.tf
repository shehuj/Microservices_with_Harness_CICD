resource "harness_platform_secret_text" "github_pat" {
  name                      = "GitHub PAT"
  identifier                = "github_pat"
  org_id                    = var.org_id
  project_id                = var.project_id
  secret_manager_identifier = "harnessSecretManager"
  value                     = "<+input>"
  value_type                = "Inline"
}

resource "harness_platform_secret_text" "docker_registry_password" {
  name                      = "Docker Registry Password"
  identifier                = "docker_registry_password"
  org_id                    = var.org_id
  project_id                = var.project_id
  secret_manager_identifier = "harnessSecretManager"
  value                     = "<+input>"
  value_type                = "Inline"
}