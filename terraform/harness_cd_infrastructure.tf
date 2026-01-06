resource "harness_platform_infrastructure" "staging_infra" {
  name       = "Staging Kubernetes Infrastructure"
  identifier = "staging_infra"
  org_id     = var.org_id
  project_id = var.project_id
  env_id     = harness_platform_environment.env.identifier
  type       = "KubernetesDirect"

  yaml = <<-EOT
infrastructureDefinition:
  name: Staging Kubernetes Infrastructure
  identifier: staging_infra
  orgIdentifier: ${var.org_id}
  projectIdentifier: ${var.project_id}
  environmentRef: ${harness_platform_environment.env.identifier}
  deploymentType: Kubernetes
  type: KubernetesDirect
  spec:
    connectorRef: ${var.k8s_connector_id}
    namespace: ${var.namespace}
    releaseName: release-<+INFRA_KEY>
  EOT

  depends_on = [harness_platform_environment.env]
}
