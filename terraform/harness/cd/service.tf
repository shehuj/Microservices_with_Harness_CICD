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
                connectorRef: ${var.github_connector_id}
                imagePath: ${var.docker_registry}/${var.service_name}
                tag: <+input>
          manifests:
            - manifest:
                type: Kubernetes
                identifier: k8s_manifest
                spec:
                  store:
                    type: Git
                    spec:
                      connectorRef: ${var.github_connector_id}
                      gitFetchType: Branch
                      branch: main
                      paths:
                        - k8s/deployment.yaml
                        - k8s/service.yaml
  EOT
}