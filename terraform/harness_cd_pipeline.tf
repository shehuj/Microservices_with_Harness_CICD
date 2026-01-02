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
          deploymentType: Kubernetes
          service:
            serviceRef: java_microservice
            serviceInputs:
              serviceDefinition:
                type: Kubernetes
                spec:
                  artifacts:
                    primary:
                      primaryArtifactRef: <+input>
                      sources: <+input>
          environment:
            environmentRef: staging
            deployToAll: false
            infrastructureDefinitions:
              - identifier: staging_infra
          execution:
            steps:
              - step:
                  name: Rolling Deployment
                  identifier: rolling_deployment
                  type: K8sRollingDeploy
                  spec:
                    skipDryRun: false
              - step:
                  name: Verify Deployment
                  identifier: verify_deployment
                  type: Wait
                  spec:
                    duration: "2m"
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
  EOT
}