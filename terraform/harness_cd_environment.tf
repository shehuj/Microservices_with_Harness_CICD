resource "harness_platform_environment" "env" {
  name       = "Staging"
  identifier = "staging"
  org_id     = var.org_id
  project_id = var.project_id
  type       = "PreProduction"

  yaml = <<-EOT
    environment:
      name: Staging
      identifier: staging
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      type: PreProduction
  EOT
}