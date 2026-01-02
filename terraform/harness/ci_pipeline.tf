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
  stages:
    - stage:
        name: Build
        identifier: Build
        type: CI
        spec:
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
                    command: |
                      docker build -t \${IMAGE} .
              - step:
                  type: Run
                  name: Push Docker
                  spec:
                    shell: Bash
                    command: |
                      docker push \${IMAGE}
 EOT
}