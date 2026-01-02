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
  properties:
    ci:
      codebase:
        connectorRef: ${var.github_connector_id}
        repoName: ${var.github_repo}
        build: <+input>
  variables:
    - name: branch
      type: String
      description: Branch to deploy from
      required: true
      value: <+input>.default(main).allowedValues(main,dev)
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
            infrastructureDefinition:
              type: KubernetesDirect
              spec:
                connectorRef: ${var.k8s_connector_id}
                namespace: ${var.namespace}
                releaseName: release-<+INFRA_KEY>
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