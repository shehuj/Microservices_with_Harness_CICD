resource "harness_platform_service" "service" {
  name       = "Java Microservice"
  identifier = "java_microservice"
  org_id     = var.org_id
  project_id = var.project_id

  yaml = <<-EOT
    service:
      name: Java Microservice
      identifier: java_microservice
      serviceDefinition:
        type: Kubernetes
        spec:
          artifacts:
            primary:
              type: DockerRegistry
              spec:
                connectorRef: ${var.docker_connector_id}
                imagePath: ${var.docker_registry}/${var.service_name}
                tag: <+input>
  EOT
}

# Manifests configuration removed - requires GitHub connector
# After creating GitHub connector via CREATE_CONNECTORS_WORKAROUND.sh script,
# add manifests manually in Harness UI or uncomment below and run terraform apply
#
# To add manifests after GitHub connector is created:
# 1. Run the CREATE_CONNECTORS_WORKAROUND.sh script to create connectors
# 2. Uncomment the manifests section below in this file
# 3. Run: terraform apply
#
# manifests:
#   - manifest:
#       type: K8sManifest
#       identifier: k8s_manifest
#       spec:
#         store:
#           type: Git
#           spec:
#             connectorRef: ${var.github_connector_id}
#             gitFetchType: Branch
#             branch: ${var.default_branch}
#             paths:
#               - k8s/deployment.yaml
#               - k8s/service.yaml