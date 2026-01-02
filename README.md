# Microservices with Harness CI/CD

Automate Java microservice deployment using Harness CI/CD pipelines provisioned with Terraform.

## Overview

This repository provides Infrastructure-as-Code (IaC) for setting up:

- **CI Pipeline**: Automatically triggered by GitHub PRs, builds and tests Java applications, creates Docker images
- **CD Pipeline**: Deploys containerized applications to Kubernetes clusters
- **Connectors**: Integrates GitHub and Kubernetes with Harness
- **Secrets Management**: Securely stores credentials in Harness

## Prerequisites

Before you begin, ensure you have:

### Required Tools

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Harness Account](https://app.harness.io) (Free tier available)
- [GitHub Account](https://github.com) with a repository for your microservice
- Kubernetes cluster (GKE, EKS, AKS, or local cluster)
- [Docker](https://www.docker.com/get-started) for local testing

### Required Access

- Harness Platform API Key with appropriate permissions
- GitHub Personal Access Token (PAT) with repo access
- Kubernetes cluster access with kubectl configured
- Docker registry credentials (Docker Hub, GHCR, GCR, etc.)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/Microservices_with_Harness_CICD.git
cd Microservices_with_Harness_CICD
```

### 2. Configure Harness

1. **Get Harness Account ID**:
   - Log in to Harness at <https://app.harness.io>
   - Navigate to Account Settings > Overview
   - Copy your Account ID

2. **Create Harness API Key**:
   - Go to Account Settings > Access Control > API Keys
   - Click "+ API Key"
   - Name it (e.g., "Terraform Automation")
   - Copy the generated key

3. **Install Harness Delegate** (if not already installed):

   ```bash
   # Follow instructions at:
   # https://developer.harness.io/docs/platform/delegates/install-delegates/overview
   ```

### 3. Configure Variables

Edit `terraform/terraform.tfvars`:

```hcl
# Harness Configuration
harness_account_id = "your-actual-account-id"
harness_api_key    = "your-actual-api-key"

# GitHub Configuration
github_repo = "your-org/your-java-microservice"

# Kubernetes Configuration
namespace          = "production"
cluster_name       = "my-prod-cluster"
cluster_region     = "us-central1"
cluster_project_id = "my-gcp-project"

# Service Configuration
service_name    = "my-java-service"
docker_registry = "docker.io"  # or ghcr.io, gcr.io, etc.

# Docker Registry Configuration
docker_username     = "your-dockerhub-username"
docker_registry_url = "https://index.docker.io/v1/"  # for Docker Hub
# For other registries:
# - GitHub Container Registry: "https://ghcr.io"
# - Google Container Registry: "https://gcr.io"
# - Azure Container Registry: "https://yourregistry.azurecr.io"
```

### 4. Configure Backend (Optional but Recommended)

For team collaboration, configure remote state in `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "harness-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 5. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

### 6. Configure Secrets in Harness

After Terraform creates the secret placeholders, update them in Harness:

1. Go to Harness > Secrets
2. Update `github_pat` with your GitHub Personal Access Token
3. Update `docker_registry_password` with your Docker registry credentials

### 7. Prepare Your Microservice Repository

Your Java microservice repository should include:

1. **pom.xml** - Maven configuration
2. **Dockerfile** - See `Dockerfile.example` in this repo
3. **src/** - Your application source code

Example structure:

```text
your-java-microservice/
├── pom.xml
├── Dockerfile
├── src/
│   └── main/
│       └── java/
└── README.md
```

### 8. Test the Pipeline

1. Create a Pull Request in your microservice repository
2. The CI pipeline should trigger automatically
3. Monitor the build in Harness CI
4. Once merged, trigger the CD pipeline to deploy to staging

## Architecture

```text
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   GitHub    │────────>│   Harness    │────────>│ Kubernetes  │
│ (Source Code)│  Webhook│   CI/CD      │ Deploy  │  Cluster    │
└─────────────┘         └──────────────┘         └─────────────┘
                               │
                               │ Manages
                               ▼
                        ┌──────────────┐
                        │  Terraform   │
                        │  (This Repo) │
                        └──────────────┘
```

## Repository Structure

```text
Microservices_with_Harness_CICD/
├── README.md                          # This file
├── Dockerfile.example                 # Example Dockerfile for Java app
├── k8s/                              # Kubernetes manifests
│   ├── deployment.yaml               # K8s Deployment configuration
│   └── service.yaml                  # K8s Service configuration
├── terraform/                        # Terraform IaC
│   ├── provider.tf                   # Harness provider config
│   ├── backend.tf                    # State backend config
│   ├── variables.tf                  # Variable definitions
│   ├── terraform.tfvars              # Variable values
│   └── harness/                      # Harness resources
│       ├── connectors.tf             # GitHub & K8s connectors
│       ├── ci_pipeline.tf            # CI pipeline definition
│       ├── triggers.tf               # Webhook triggers
│       ├── secrets.tf                # Secret management
│       ├── outputs.tf                # Terraform outputs
│       └── cd/                       # CD resources
│           ├── environment.tf        # Environment config
│           ├── service.tf            # Service definition
│           ├── infrastructure.tf     # Infrastructure spec
│           └── cd_pipeline.tf        # CD pipeline
└── .github/
    └── workflows/
        └── pr-validation.yml         # GitHub Actions workflow
```

## CI/CD Workflows

### CI Pipeline (Continuous Integration)

Triggered on: Pull Request to `main` branch

Steps:

1. **Build & Test**: Runs `mvn clean verify`
2. **Build Docker**: Creates container image with tag `<registry>/<service>:<build-id>`
3. **Push Docker**: Pushes image to configured Docker registry

### CD Pipeline (Continuous Deployment)

Triggered: Manually or after successful CI

Steps:

1. **Deploy to Staging**: Applies Kubernetes manifests from Git
2. **Verification**: Waits for deployment stability
3. **Health Check**: Validates application endpoints

## Recent Changes

### Configuration Fixes (2026-01-02)

The following issues have been fixed:

1. **Port Alignment**: Updated application port from 8070 to 8080 to match Kubernetes deployment configuration
2. **Health Checks**: Added Spring Boot Actuator dependency and configured health endpoints at `/health` for Spring Boot 1.5.x compatibility
3. **Docker Registry Connector**: Added proper Docker registry connector in Terraform instead of incorrectly using GitHub connector for Docker images
4. **GitHub Actions Fix**: Corrected syntax error in terraform.yml workflow and added proper working directory
5. **Terraform Variables**: Added new variables for Docker registry configuration (`docker_connector_id`, `docker_registry_url`, `docker_username`)

### Known Limitations

1. **Spring Boot Version**: The shopping cart demo app uses Spring Boot 1.5.3.RELEASE (2017), which is EOL and may contain security vulnerabilities. Consider upgrading to Spring Boot 2.x or 3.x for production use.
2. **Hardcoded Credentials**: Admin credentials are hardcoded in application.properties. Use environment variables for production deployments.
3. **Auto-Apply Risk**: The GitHub Actions workflow automatically applies Terraform changes on push to main without manual approval. Consider adding a manual approval step for production environments.
4. **Resource Limits**: Kubernetes deployment has conservative memory limits (512Mi) that may need adjustment for production Java workloads.

## Configuration Reference

### Variables

| Variable | Description | Example |
| -------- | ----------- | ------- |
| `harness_account_id` | Harness account identifier | `abc123xyz` |
| `harness_api_key` | Harness Platform API key | `pat.xyz...` |
| `org_id` | Harness organization | `default` |
| `project_id` | Harness project identifier | `java-microservice` |
| `github_repo` | GitHub repository path | `myorg/my-service` |
| `github_connector_id` | GitHub connector ID | `github-conn` |
| `k8s_connector_id` | Kubernetes connector ID | `k8s-conn` |
| `docker_connector_id` | Docker registry connector ID | `docker-conn` |
| `docker_registry_url` | Docker registry API URL | `https://index.docker.io/v1/` |
| `docker_username` | Docker registry username | `your-dockerhub-user` |
| `namespace` | K8s namespace | `production` |
| `cluster_name` | Kubernetes cluster name | `prod-cluster-01` |
| `cluster_region` | Cloud region | `us-central1` |
| `cluster_project_id` | Cloud project ID | `my-gcp-project` |
| `service_name` | Microservice name | `user-service` |
| `docker_registry` | Docker registry base path | `docker.io` |

### Secrets

The following secrets need to be configured in Harness:

- `github_pat`: GitHub Personal Access Token
- `docker_registry_password`: Docker registry authentication

## Troubleshooting

### Terraform Apply Fails

**Issue**: Authentication error with Harness

```text
Error: Unable to authenticate with Harness
```

**Solution**:

- Verify `harness_account_id` is correct
- Ensure `harness_api_key` is valid and not expired
- Check API key has necessary permissions

### CI Pipeline Not Triggering

**Issue**: Pull requests don't trigger the CI pipeline

**Solution**:

- Verify GitHub webhook is configured correctly
- Check Harness trigger settings in the UI
- Ensure GitHub connector has valid PAT
- Verify repository name matches `github_repo` variable

### Docker Push Fails

**Issue**: `unauthorized: authentication required`

**Solution**:

- Update `docker_registry_password` secret in Harness
- Ensure Docker registry URL is correct
- Verify Docker registry supports the authentication method

### Kubernetes Deployment Fails

**Issue**: Unable to deploy to cluster

**Solution**:

- Verify Kubernetes connector is configured correctly
- Check Harness Delegate is running and has cluster access
- Ensure namespace exists in the cluster
- Review RBAC permissions for the service account

### Pipeline Shows "IMAGE Not Found"

**Issue**: CI pipeline fails at Docker build step

**Solution**: This issue has been fixed in the latest version. If you're using an older version:

- Update `terraform/harness/ci_pipeline.tf` to use the fixed version
- Run `terraform apply` to update the pipeline

## Best Practices

1. **Never commit sensitive data**: Use Harness secrets for credentials
2. **Use remote backend**: Configure S3/GCS backend for team collaboration
3. **Enable state locking**: Prevent concurrent Terraform runs
4. **Review plans**: Always run `terraform plan` before `apply`
5. **Tag your images**: Use semantic versioning for Docker images
6. **Monitor deployments**: Set up alerts in Harness for pipeline failures
7. **Use separate environments**: Create distinct pipelines for dev/staging/prod

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a Pull Request

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Support

For issues and questions:

- GitHub Issues: [Create an issue](https://github.com/your-org/Microservices_with_Harness_CICD/issues)
- Harness Docs: <https://developer.harness.io>
- Terraform Docs: <https://registry.terraform.io/providers/harness/harness/latest/docs>
