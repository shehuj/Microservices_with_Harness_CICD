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
                imagePath: ${var.docker_username}/${var.service_name}
                tag: <+input>.regex(^[a-zA-Z0-9_.-]+$)
          manifests:
            - manifest:
                identifier: k8s_files
                type: K8sManifest
                spec:
                  store:
                    type: Git
                    spec:
                      connectorRef: ${var.github_connector_id}
                      gitFetchType: Branch
                      branch: ${var.default_branch}
                      paths:
                        - k8s/
  EOT
}