resource "harness_platform_pipeline" "ci_pipeline" {
  name       = "CI Java Microservice"
  identifier = "ci_java_microservice"
  project_id = var.project_id
  org_id     = var.org_id

  yaml = <<EOT
pipeline:
  name: CI Java Microservice
  identifier: ci_java_microservice
  projectIdentifier: ${var.project_id}
  orgIdentifier: ${var.org_id}
  properties:
    ci:
      codebase:
        connectorRef: ${var.github_connector_id}
        repoName: ${var.github_repo}
        build: <+input>
  variables:
    - name: DOCKER_REGISTRY
      type: String
      value: ${var.docker_registry}
    - name: SERVICE_NAME
      type: String
      value: ${var.service_name}
  stages:
    - stage:
        name: Build
        identifier: Build
        type: CI
        spec:
          cloneCodebase: true
          infrastructure:
            type: KubernetesDirect
            spec:
              connectorRef: ${var.k8s_connector_id}
              namespace: ${var.namespace}
          execution:
            steps:
              - step:
                  type: Run
                  name: Build & Test
                  spec:
                    shell: Bash
                    command: |
                      mvn clean verify
              - step:
                  type: Run
                  name: Build Docker
                  spec:
                    shell: Bash
                    envVariables:
                      IMAGE: <+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>:<+pipeline.sequenceId>
                    command: |
                      docker build -t \$IMAGE .
              - step:
                  type: Run
                  name: Push Docker
                  spec:
                    shell: Bash
                    envVariables:
                      IMAGE: <+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>:<+pipeline.sequenceId>
                    command: |
                      docker push \$IMAGE
 EOT
}