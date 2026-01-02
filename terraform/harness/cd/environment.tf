resource "harness_platform_environment" "env" {
  name       = "Staging"
  identifier = "staging"
  org_id     = var.org_id
  project_id = var.project_id

  yaml = <<-EOT
    environment:
      name: Staging
      identifier: staging
      type: PreProduction
  EOT
}