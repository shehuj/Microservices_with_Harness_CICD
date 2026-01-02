resource "harness_platform_pipeline" "cd_pipeline" {
  name       = "CD Deploy Java Microservice"
  identifier = "cd_deploy_java_microservice"
  project_id = var.project_id
  org_id     = var.org_id

  yaml = <<-EOT
pipeline:
  name: CD Deploy Java Microservice
  identifier: cd_deploy_java_microservice
  projectIdentifier: ${var.project_id}
  orgIdentifier: ${var.org_id}
  stages:
    - stage:
        name: Deploy to Staging
        identifier: Deploy_Staging
        type: Deployment
        spec:
          environment:
            environmentRef: staging
          infrastructure:
            infrastructureDefinitionRef: staging_k8s
          execution:
            steps:
              - step:
                  name: Deploy Kubernetes
                  type: KubernetesApply
                  spec:
                    manifests:
                      - manifest:
                          type: Kubernetes
                          identifier: k8s_deployment
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
              - step:
                  name: Verify Deployment
                  type: Wait
                  spec:
                    duration: "2m"
  EOT
}