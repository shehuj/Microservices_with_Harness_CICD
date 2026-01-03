#!/bin/bash
#
# Complete Harness CI/CD Setup
#
# This script walks you through the complete setup process:
# 1. Create Harness resources via Terraform
# 2. Create connectors via API (workaround for provider bug)
# 3. Enable CI pipeline codebase
# 4. Enable service manifests
#
# Usage: ./complete_setup.sh

set -e

echo "========================================="
echo "Complete Harness CI/CD Setup"
echo "========================================="
echo ""
echo "This script will guide you through the complete setup."
echo ""

# Step 1: Check prerequisites
echo "Step 1: Checking Prerequisites"
echo "========================================="
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "✗ terraform.tfvars not found!"
    echo "Please create terraform.tfvars with your configuration."
    exit 1
fi
echo "✓ terraform.tfvars found"

# Check if Harness API key is set
if ! grep -q "harness_api_key" terraform.tfvars || grep -q "CHANGE_ME" terraform.tfvars; then
    echo "✗ Harness API key not configured!"
    echo "Please set harness_api_key in terraform.tfvars"
    exit 1
fi
echo "✓ Harness API key configured"

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "⚠️  Terraform not initialized"
    echo "Running: terraform init"
    terraform init
fi
echo "✓ Terraform initialized"

echo ""

# Step 2: Deploy base resources
echo "Step 2: Deploy Base Harness Resources"
echo "========================================="
echo ""
echo "This will create:"
echo "  - Secrets (github_pat, docker_registry_password)"
echo "  - K8s Connector"
echo "  - CI Pipeline (without codebase)"
echo "  - CD Pipeline"
echo "  - Service (without manifests)"
echo "  - Environment"
echo "  - Trigger"
echo ""
read -p "Deploy base resources now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply
    if [ $? -ne 0 ]; then
        echo "✗ Terraform apply failed!"
        exit 1
    fi
    echo ""
    echo "✓ Base resources created"
else
    echo "Skipped base resource deployment"
    echo "Run 'terraform apply' manually when ready"
    exit 0
fi
echo ""

# Step 3: Create connectors via API
echo "Step 3: Create Connectors via API"
echo "========================================="
echo ""
echo "Due to Harness provider bug, we need to create these via API:"
echo "  - GitHub Connector"
echo "  - Docker Connector"
echo "  - Infrastructure Definition"
echo ""
read -p "Create connectors now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f "CREATE_CONNECTORS_WORKAROUND.sh" ]; then
        echo "✗ CREATE_CONNECTORS_WORKAROUND.sh not found!"
        exit 1
    fi

    ./CREATE_CONNECTORS_WORKAROUND.sh
    if [ $? -ne 0 ]; then
        echo "✗ Connector creation failed!"
        exit 1
    fi
    echo ""
    echo "✓ Connectors created"
else
    echo "Skipped connector creation"
    echo "Run './CREATE_CONNECTORS_WORKAROUND.sh' manually when ready"
    exit 0
fi
echo ""

# Step 4: Enable CI pipeline codebase
echo "Step 4: Enable CI Pipeline Codebase"
echo "========================================="
echo ""
echo "This will update the CI pipeline to:"
echo "  - Add codebase configuration"
echo "  - Enable code checkout from GitHub"
echo ""
read -p "Enable CI codebase now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f "enable_ci_codebase.sh" ]; then
        echo "✗ enable_ci_codebase.sh not found!"
        exit 1
    fi

    ./enable_ci_codebase.sh
    if [ $? -ne 0 ]; then
        echo "✗ CI codebase enablement failed!"
        exit 1
    fi
    echo ""
    echo "✓ CI codebase enabled"
else
    echo "Skipped CI codebase enablement"
    echo "Run './enable_ci_codebase.sh' manually when ready"
    exit 0
fi
echo ""

# Step 5: Enable service manifests
echo "Step 5: Enable Service Manifests"
echo "========================================="
echo ""
echo "This will update the service to:"
echo "  - Add Kubernetes manifest configuration"
echo "  - Pull manifests from GitHub repository"
echo ""
read -p "Enable service manifests now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f "enable_service_manifests.sh" ]; then
        echo "✗ enable_service_manifests.sh not found!"
        exit 1
    fi

    ./enable_service_manifests.sh
    if [ $? -ne 0 ]; then
        echo "✗ Service manifests enablement failed!"
        exit 1
    fi
    echo ""
    echo "✓ Service manifests enabled"
else
    echo "Skipped service manifests enablement"
    echo "Run './enable_service_manifests.sh' manually when ready"
    exit 0
fi
echo ""

# Final summary
echo "========================================="
echo "✓ Setup Complete!"
echo "========================================="
echo ""
echo "Your Harness CI/CD infrastructure is now fully configured:"
echo ""
echo "✓ All Harness resources created"
echo "✓ GitHub connector configured"
echo "✓ Docker connector configured"
echo "✓ Infrastructure definition created"
echo "✓ CI pipeline can checkout and build code"
echo "✓ Service has Kubernetes manifests"
echo "✓ CD pipeline can deploy to Kubernetes"
echo ""
echo "Next Steps:"
echo "1. Update secrets in Harness UI:"
echo "   - github_pat → Your GitHub Personal Access Token"
echo "   - docker_registry_password → Your Docker registry password"
echo ""
echo "2. Verify delegate is connected:"
echo "   - Go to: Account Settings > Delegates"
echo "   - Status should show: Connected"
echo ""
echo "3. Test your pipelines:"
echo "   - Trigger CI pipeline to build code"
echo "   - Run CD pipeline to deploy to Kubernetes"
echo ""
echo "Documentation:"
echo "  - QUICKSTART.md - Quick reference"
echo "  - PROVIDER_BUG_WORKAROUND.md - Detailed workaround info"
echo "  - DELEGATE_TOKEN_SETUP.md - Delegate configuration"
echo ""
echo "Enjoy your automated CI/CD pipeline!"
