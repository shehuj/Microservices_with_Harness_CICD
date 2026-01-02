resource "harness_platform_infrastructure" "infra" {
  name       = "Staging Kubernetes"
  identifier = "staging_k8s"
  org_id     = var.org_id
  project_id = var.project_id
  env_id     = harness_platform_environment.env.identifier

  yaml = <<-EOT
    infrastructureDefinition:
      name: Staging Kubernetes
      identifier: staging_k8s
      environmentRef: staging
      deploymentType: Kubernetes
      type: KubernetesDirect
      spec:
        connectorRef: ${var.k8s_connector_id}
        namespace: ${var.namespace}
  EOT
}