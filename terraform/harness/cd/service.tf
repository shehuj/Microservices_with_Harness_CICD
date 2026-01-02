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
                connectorRef: github-conn
                imagePath: your-docker-repo/java-microservice
          manifests:
            - manifest:
                type: Kubernetes
                identifier: k8s_manifest
                spec:
                  store:
                    type: Git
                    spec:
                      connectorRef: github-conn
                      gitFetchType: Branch
                      branch: main
                      paths:
                        - k8s/deployment.yaml
                        - k8s/service.yaml
  EOT
}