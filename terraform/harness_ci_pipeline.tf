resource "harness_platform_pipeline" "ci_pipeline" {
  name       = "CI Java Microservice"
  identifier = "ci_java_microservice"
  project_id = var.project_id
  org_id     = var.org_id

  yaml = <<-EOT
pipeline:
  name: CI Java Microservice
  identifier: ci_java_microservice
  orgIdentifier: ${var.org_id}
  projectIdentifier: ${var.project_id}

  properties:
    ci:
      codebase:
        connectorRef: github_conn
        repoName: ${var.github_repo}
        build: <+input>

  variables:
    - name: branch
      type: String
      value: <+input>
      default: "main"
      allowedValues:
        - "main"
        - "dev"

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
                  name: Build and Test
                  identifier: build_test
                  type: Run
                  spec:
                    image: maven:3.9.6-eclipse-temurin-17
                    shell: Bash
                    command: |
                      mvn clean verify
                  timeout: 10m
                  failureStrategies:
                    - onFailure:
                        errors:
                          - AllErrors
                        action:
                          type: Retry
                          spec:
                            retryCount: 1
                            retryIntervals:
                              - "10s"
                            onRetryFailure:
                              action:
                                type: Abort

              - step:
                  name: Build and Push Docker Image
                  identifier: build_push
                  type: BuildAndPushDockerRegistry
                  spec:
                    connectorRef: docker_registry_conn
                    repo: "<+pipeline.variables.SERVICE_NAME>"
                    tags:
                      - "<+pipeline.sequenceId>"
                    dockerfile: "Dockerfile"
                    context: "."

                  timeout: 10m
                  failureStrategies:
                    - onFailure:
                        errors:
                          - AllErrors
                        action:
                          type: Retry
                          spec:
                            retryCount: 2
                            retryIntervals:
                              - "10s"
                              - "20s"
                            onRetryFailure:
                              action:
                                type: Abort

        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: Abort

  EOT
}