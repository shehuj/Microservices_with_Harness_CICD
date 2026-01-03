#!/bin/bash
#
# Workaround Script to Create Harness Connectors via API
#
# This script creates the GitHub, Docker, and Infrastructure resources
# that cannot be created via Terraform due to provider bug v0.39.4
#
# Usage: ./CREATE_CONNECTORS_WORKAROUND.sh
#
# Prerequisites:
# - HARNESS_API_KEY environment variable set
# - HARNESS_ACCOUNT_ID environment variable set
# - jq installed for JSON processing

set -e

# Load variables from terraform.tfvars
HARNESS_ACCOUNT_ID="${HARNESS_ACCOUNT_ID:-$(grep 'harness_account_id' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
HARNESS_API_KEY="${HARNESS_API_KEY:-$(grep 'harness_api_key' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
ORG_ID="${ORG_ID:-$(grep 'org_id' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
PROJECT_ID="${PROJECT_ID:-$(grep 'project_id' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
GITHUB_REPO="${GITHUB_REPO:-$(grep 'github_repo' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
DOCKER_USERNAME="${DOCKER_USERNAME:-$(grep 'docker_username' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
DOCKER_REGISTRY_URL="${DOCKER_REGISTRY_URL:-$(grep 'docker_registry_url' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"
NAMESPACE="${NAMESPACE:-$(grep 'namespace' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')}"

HARNESS_API="https://app.harness.io/gateway/ng/api"

echo "========================================="
echo "Harness Connector Creation Workaround"
echo "========================================="
echo ""
echo "Account ID: $HARNESS_ACCOUNT_ID"
echo "Org ID: $ORG_ID"
echo "Project ID: $PROJECT_ID"
echo ""

# Function to create GitHub connector
create_github_connector() {
    echo "Creating GitHub Connector..."

    curl -X POST "${HARNESS_API}/connectors" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${HARNESS_API_KEY}" \
        -d "{
            \"connector\": {
                \"name\": \"GitHub Connector\",
                \"identifier\": \"github_conn\",
                \"description\": \"GitHub connector for repository access\",
                \"orgIdentifier\": \"${ORG_ID}\",
                \"projectIdentifier\": \"${PROJECT_ID}\",
                \"type\": \"Github\",
                \"spec\": {
                    \"url\": \"https://github.com\",
                    \"validationRepo\": \"${GITHUB_REPO}\",
                    \"authentication\": {
                        \"type\": \"Http\",
                        \"spec\": {
                            \"type\": \"UsernameToken\",
                            \"spec\": {
                                \"username\": \"${GITHUB_REPO}\",
                                \"tokenRef\": \"${ORG_ID}.${PROJECT_ID}.github_pat\"
                            }
                        }
                    },
                    \"apiAccess\": null,
                    \"delegateSelectors\": [],
                    \"executeOnDelegate\": false,
                    \"type\": \"Account\"
                }
            }
        }"

    echo ""
    echo "✓ GitHub Connector created"
}

# Function to create Docker connector
create_docker_connector() {
    echo "Creating Docker Registry Connector..."

    curl -X POST "${HARNESS_API}/connectors" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${HARNESS_API_KEY}" \
        -d "{
            \"connector\": {
                \"name\": \"Docker Registry Connector\",
                \"identifier\": \"docker_conn\",
                \"description\": \"Docker registry connector for image storage\",
                \"orgIdentifier\": \"${ORG_ID}\",
                \"projectIdentifier\": \"${PROJECT_ID}\",
                \"type\": \"DockerRegistry\",
                \"spec\": {
                    \"dockerRegistryUrl\": \"${DOCKER_REGISTRY_URL}\",
                    \"providerType\": \"DockerHub\",
                    \"auth\": {
                        \"type\": \"UsernamePassword\",
                        \"spec\": {
                            \"username\": \"${DOCKER_USERNAME}\",
                            \"passwordRef\": \"${ORG_ID}.${PROJECT_ID}.docker_registry_password\"
                        }
                    },
                    \"delegateSelectors\": [],
                    \"executeOnDelegate\": false
                }
            }
        }"

    echo ""
    echo "✓ Docker Registry Connector created"
}

# Function to create infrastructure
create_infrastructure() {
    echo "Creating Infrastructure Definition..."

    curl -X POST "${HARNESS_API}/infrastructures" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${HARNESS_API_KEY}" \
        -d "{
            \"identifier\": \"staging_k8s\",
            \"orgIdentifier\": \"${ORG_ID}\",
            \"projectIdentifier\": \"${PROJECT_ID}\",
            \"environmentRef\": \"staging\",
            \"name\": \"Staging Kubernetes\",
            \"description\": \"Kubernetes infrastructure for staging\",
            \"tags\": {},
            \"type\": \"KubernetesDirect\",
            \"yaml\": \"infrastructureDefinition:\\n  name: Staging Kubernetes\\n  identifier: staging_k8s\\n  orgIdentifier: ${ORG_ID}\\n  projectIdentifier: ${PROJECT_ID}\\n  environmentRef: staging\\n  deploymentType: Kubernetes\\n  type: KubernetesDirect\\n  spec:\\n    connectorRef: k8s_conn\\n    namespace: ${NAMESPACE}\\n    releaseName: release-<+INFRA_KEY>\"
        }"

    echo ""
    echo "✓ Infrastructure Definition created"
}

# Main execution
echo "This script will create the following resources via Harness API:"
echo "  1. GitHub Connector (github_conn)"
echo "  2. Docker Registry Connector (docker_conn)"
echo "  3. Infrastructure Definition (staging_k8s)"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    create_github_connector
    echo ""
    create_docker_connector
    echo ""
    create_infrastructure
    echo ""
    echo "========================================="
    echo "All resources created successfully!"
    echo "========================================="
    echo ""
    echo "Note: You can now import these resources into Terraform state using:"
    echo "  terraform import harness_platform_connector_github.github ${ORG_ID}/${PROJECT_ID}/github_conn"
    echo "  terraform import harness_platform_connector_docker.docker_registry ${ORG_ID}/${PROJECT_ID}/docker_conn"
    echo "  terraform import harness_platform_infrastructure.infra ${ORG_ID}/${PROJECT_ID}/staging/staging_k8s"
else
    echo "Cancelled."
    exit 1
fi
