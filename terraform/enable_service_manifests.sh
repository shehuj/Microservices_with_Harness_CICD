#!/bin/bash
#
# Enable Service Manifests Configuration
#
# This script updates the service to add Kubernetes manifest configuration
# after the GitHub connector has been created.
#
# Prerequisites:
# - GitHub connector must exist in Harness (run CREATE_CONNECTORS_WORKAROUND.sh first)
#
# Usage: ./enable_service_manifests.sh

set -e

echo "========================================="
echo "Enable Service Manifests"
echo "========================================="
echo ""

# Load variables from terraform.tfvars
GITHUB_CONNECTOR_ID=$(grep 'github_connector_id' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
DEFAULT_BRANCH=$(grep 'default_branch' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')

echo "GitHub Connector: $GITHUB_CONNECTOR_ID"
echo "Default Branch: $DEFAULT_BRANCH"
echo ""

# Backup the original file
echo "Creating backup of harness_cd_service.tf..."
cp harness_cd_service.tf harness_cd_service.tf.backup
echo "✓ Backup created: harness_cd_service.tf.backup"
echo ""

# Check if manifests are already configured
if grep -q "manifests:" harness_cd_service.tf; then
    echo "⚠️  Manifests configuration already exists!"
    echo "The service already has the manifests section."
    echo ""
    read -p "Do you want to reconfigure it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Create the updated service file
echo "Updating service configuration..."

cat > harness_cd_service.tf << 'OUTER_EOF'
resource "harness_platform_service" "service" {
  name       = "Java Microservice"
  identifier = "java_microservice"
  org_id     = var.org_id
  project_id = var.project_id

  yaml = <<-EOT
    service:
      name: Java Microservice
      identifier: java_microservice
      serviceDefinition:
        type: Kubernetes
        spec:
          artifacts:
            primary:
              type: DockerRegistry
              spec:
                connectorRef: ${var.docker_connector_id}
                imagePath: ${var.docker_registry}/${var.service_name}
                tag: <+input>
          manifests:
            - manifest:
                type: K8sManifest
                identifier: k8s_manifest
                spec:
                  store:
                    type: Git
                    spec:
                      connectorRef: ${var.github_connector_id}
                      gitFetchType: Branch
                      branch: ${var.default_branch}
                      paths:
                        - k8s/deployment.yaml
                        - k8s/service.yaml
  EOT
}
OUTER_EOF

echo "✓ Service configuration updated"
echo ""

# Validate the new configuration
echo "Validating Terraform configuration..."
if terraform validate > /dev/null 2>&1; then
    echo "✓ Configuration is valid"
else
    echo "✗ Configuration validation failed!"
    echo ""
    echo "Restoring backup..."
    mv harness_cd_service.tf.backup harness_cd_service.tf
    echo "✓ Backup restored"
    exit 1
fi
echo ""

# Show the changes
echo "========================================="
echo "Changes Made:"
echo "========================================="
echo "1. ✓ Added manifests section to service"
echo "2. ✓ Set connectorRef to: $GITHUB_CONNECTOR_ID"
echo "3. ✓ Set branch to: $DEFAULT_BRANCH"
echo "4. ✓ Configured manifest paths:"
echo "     - k8s/deployment.yaml"
echo "     - k8s/service.yaml"
echo ""

# Ask to apply changes
echo "========================================="
echo "Ready to Apply Changes"
echo "========================================="
echo ""
echo "The service will be updated to:"
echo "  - Pull K8s manifests from GitHub"
echo "  - Using connector: $GITHUB_CONNECTOR_ID"
echo "  - From branch: $DEFAULT_BRANCH"
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
        echo "✓ Service Updated Successfully!"
        echo "========================================="
        echo ""
        echo "The service now has Kubernetes manifests:"
        echo "  ✓ Manifests will be pulled from GitHub"
        echo "  ✓ Using deployment.yaml and service.yaml"
        echo "  ✓ CD pipeline can now deploy to Kubernetes"
        echo ""
        echo "Backup file saved as: harness_cd_service.tf.backup"
    else
        echo ""
        echo "✗ Terraform apply failed!"
        echo ""
        echo "Restoring backup..."
        mv harness_cd_service.tf.backup harness_cd_service.tf
        echo "✓ Backup restored"
        exit 1
    fi
else
    echo ""
    echo "Changes saved but not applied."
    echo "To apply later, run: terraform apply"
    echo ""
    echo "To restore the backup:"
    echo "  mv harness_cd_service.tf.backup harness_cd_service.tf"
fi
