#!/bin/bash
#
# Enable CI Pipeline Codebase Configuration
#
# This script updates the CI pipeline to enable code checkout after
# the GitHub connector has been created.
#
# Prerequisites:
# - GitHub connector must exist in Harness (run CREATE_CONNECTORS_WORKAROUND.sh first)
#
# Usage: ./enable_ci_codebase.sh

set -e

echo "========================================="
echo "Enable CI Pipeline Codebase"
echo "========================================="
echo ""

# Load variables from terraform.tfvars
GITHUB_REPO=$(grep 'github_repo' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
GITHUB_CONNECTOR_ID=$(grep 'github_connector_id' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')

echo "Repository: $GITHUB_REPO"
echo "GitHub Connector: $GITHUB_CONNECTOR_ID"
echo ""

# Backup the original file
echo "Creating backup of harness_ci_pipeline.tf..."
cp harness_ci_pipeline.tf harness_ci_pipeline.tf.backup
echo "✓ Backup created: harness_ci_pipeline.tf.backup"
echo ""

# Check if codebase is already configured
if grep -q "properties:" harness_ci_pipeline.tf; then
    echo "⚠️  Codebase configuration already exists!"
    echo "The CI pipeline already has the codebase section."
    echo ""
    read -p "Do you want to reconfigure it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Create the updated CI pipeline file
echo "Updating CI pipeline configuration..."

cat > harness_ci_pipeline.tf << 'OUTER_EOF'
# CI Pipeline - Codebase configuration
#
# This pipeline is configured to checkout code from GitHub

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
  properties:
    ci:
      codebase:
        connectorRef: ${var.github_connector_id}
        repoName: ${var.github_repo}
        build: <+input>
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
OUTER_EOF

echo "✓ CI pipeline configuration updated"
echo ""

# Validate the new configuration
echo "Validating Terraform configuration..."
if terraform validate > /dev/null 2>&1; then
    echo "✓ Configuration is valid"
else
    echo "✗ Configuration validation failed!"
    echo ""
    echo "Restoring backup..."
    mv harness_ci_pipeline.tf.backup harness_ci_pipeline.tf
    echo "✓ Backup restored"
    exit 1
fi
echo ""

# Show the changes
echo "========================================="
echo "Changes Made:"
echo "========================================="
echo "1. ✓ Added properties.ci.codebase section"
echo "2. ✓ Set connectorRef to: $GITHUB_CONNECTOR_ID"
echo "3. ✓ Set repoName to: $GITHUB_REPO"
echo "4. ✓ Changed cloneCodebase: false → true"
echo ""

# Ask to apply changes
echo "========================================="
echo "Ready to Apply Changes"
echo "========================================="
echo ""
echo "The CI pipeline will be updated to:"
echo "  - Checkout code from: $GITHUB_REPO"
echo "  - Using connector: $GITHUB_CONNECTOR_ID"
echo "  - Enable code cloning"
echo ""
read -p "Apply changes now with 'terraform apply'? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Running terraform apply..."
    terraform apply

    if [ $? -eq 0 ]; then
        echo ""
        echo "========================================="
        echo "✓ CI Pipeline Updated Successfully!"
        echo "========================================="
        echo ""
        echo "The CI pipeline is now fully functional:"
        echo "  ✓ Code will be cloned from GitHub"
        echo "  ✓ Maven build will run in java-app/"
        echo "  ✓ Docker image will be built and pushed"
        echo ""
        echo "You can now trigger the pipeline in Harness UI!"
        echo ""
        echo "Backup file saved as: harness_ci_pipeline.tf.backup"
    else
        echo ""
        echo "✗ Terraform apply failed!"
        echo ""
        echo "Restoring backup..."
        mv harness_ci_pipeline.tf.backup harness_ci_pipeline.tf
        echo "✓ Backup restored"
        exit 1
    fi
else
    echo ""
    echo "Changes saved but not applied."
    echo "To apply later, run: terraform apply"
    echo ""
    echo "To restore the backup:"
    echo "  mv harness_ci_pipeline.tf.backup harness_ci_pipeline.tf"
fi
