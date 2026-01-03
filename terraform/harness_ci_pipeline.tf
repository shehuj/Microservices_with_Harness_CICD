# CI Pipeline - Codebase configuration removed due to provider bug
#
# IMPORTANT: After creating GitHub connector via CREATE_CONNECTORS_WORKAROUND.sh:
# 1. Add properties.ci.codebase section after orgIdentifier
# 2. Change cloneCodebase from false to true
#
# properties:
#   ci:
#     codebase:
#       connectorRef: ${var.github_connector_id}
#       repoName: ${var.github_repo}
#       build: <+input>
#
# And in the Build stage spec, change:
#   cloneCodebase: false  -->  cloneCodebase: true

resource "harness_platform_pipeline" "ci_pipeline" {
  name       = "CI Java Microservice"
  identifier = "ci_java_microservice"
  project_id = var.project_id
  org_id     = var.org_id

  yaml = <<-EOT
pipeline:
  name: CI Java Microservice
  identifier: ci_java_microservice
  projectIdentifier: ${var.project_id}
  orgIdentifier: ${var.org_id}
  variables:
    - name: branch
      type: String
      description: Branch to build from
      required: true
      value: <+input>.default(main).allowedValues(main,dev)
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
          cloneCodebase: false
          infrastructure:
            type: KubernetesDirect
            spec:
              connectorRef: ${var.k8s_connector_id}
              namespace: ${var.namespace}
          execution:
            steps:
              - step:
                  type: Run
                  name: Build and Test
                  identifier: build_test
                  spec:
                    connectorRef: ${var.k8s_connector_id}
                    image: maven:3-openjdk-8
                    shell: Bash
                    command: |
                      cd java-app
                      mvn clean verify
              - step:
                  type: Run
                  name: Build Docker
                  identifier: build_docker
                  spec:
                    connectorRef: ${var.k8s_connector_id}
                    image: docker:latest
                    shell: Bash
                    envVariables:
                      IMAGE: <+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>:<+pipeline.sequenceId>
                    command: |
                      cd java-app
                      docker build -t \$IMAGE .
              - step:
                  type: Run
                  name: Push Docker
                  identifier: push_docker
                  spec:
                    connectorRef: ${var.k8s_connector_id}
                    image: docker:latest
                    shell: Bash
                    envVariables:
                      IMAGE: <+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>:<+pipeline.sequenceId>
                    command: |
                      docker push \$IMAGE
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: Abort
 EOT
}