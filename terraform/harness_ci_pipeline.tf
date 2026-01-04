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
                    connectorRef: ${var.k8s_connector_id}
                    image: maven:3-openjdk-8
                    shell: Bash
                    command: |
                      cd java-app
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
                    connectorRef: ${var.docker_connector_id}
                    repo: "${var.docker_username}/<+pipeline.variables.SERVICE_NAME>"
                    tags:
                      - "<+pipeline.sequenceId>"
                    dockerfile: "java-app/Dockerfile"
                    context: "java-app"

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

              - step:
                  name: Container Image Scan
                  identifier: container_scan
                  type: AquaTrivy
                  spec:
                    mode: orchestration
                    config: default
                    target:
                      type: container
                      name: "<+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>"
                      variant: "<+pipeline.sequenceId>"
                    advanced:
                      log:
                        level: info
                    privileged: true
                    image:
                      type: docker_v2
                      name: "<+pipeline.variables.DOCKER_REGISTRY>/<+pipeline.variables.SERVICE_NAME>"
                      tag: "<+pipeline.sequenceId>"

                  timeout: 5m
                  failureStrategies:
                    - onFailure:
                        errors:
                          - AllErrors
                        action:
                          type: Ignore

        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: Abort

  EOT
}