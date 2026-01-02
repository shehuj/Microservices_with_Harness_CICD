resource "harness_platform_encrypted_text" "github_pat" {
  name       = "GitHub PAT"
  identifier = "GITHUB_PAT"
  org_id     = var.org_id
  project_id = var.project_id
  value      = "<+input>"
}

resource "harness_platform_encrypted_text" "docker_registry_password" {
  name       = "Registry Password"
  identifier = "REGISTRY_PASSWORD"
  org_id     = var.org_id
  project_id = var.project_id
  value      = "<+input>"
}