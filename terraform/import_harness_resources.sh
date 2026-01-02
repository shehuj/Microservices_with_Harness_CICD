#!/bin/bash
# Import existing Harness resources into Terraform state

echo "Importing Harness resources into Terraform state..."

# Set variables
ORG_ID="default"
PROJECT_ID="belenshi"

# Import secrets
echo "Importing secrets..."
terraform import "harness_platform_secret_text.github_pat" "${ORG_ID}/${PROJECT_ID}/github_pat"
terraform import "harness_platform_secret_text.docker_registry_password" "${ORG_ID}/${PROJECT_ID}/docker_registry_password"

# Import connectors
echo "Importing connectors..."
terraform import "harness_platform_connector_kubernetes.k8s" "k8s_conn"

# Import environment
echo "Importing environment..."
terraform import "harness_platform_environment.env" "staging"

# Import service
echo "Importing service..."
terraform import "harness_platform_service.service" "java_microservice"

# Import pipelines
echo "Importing pipelines..."
terraform import "harness_platform_pipeline.ci_pipeline" "ci_java_microservice"
terraform import "harness_platform_pipeline.cd_pipeline" "cd_deploy_java_microservice"

# Import trigger
echo "Importing trigger..."
terraform import "harness_platform_triggers.pr_trigger" "github_pr_trigger"

echo ""
echo "✓ Import complete! Run 'terraform state list' to verify."
