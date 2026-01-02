# Microservices_with_Harness_CICD


# Harness CI/CD Terraform Automation

Deploy a Java microservice with:
- CI pipeline triggered by GitHub PRs
- CD pipeline that deploys to Kubernetes using Harness
- Infrastructure provisioning using Terraform

## Structure

- `terraform/harness/`: Terraform code to provision CI & CD
- `github/workflows/`: GitHub Actions validation

harness-cicd-terraform/
├── README.md
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── harness/
│   │   ├── connectors.tf
│   │   ├── ci_pipeline.tf
│   │   ├── triggers.tf
│   │   ├── secrets.tf
│   │   ├── cd/
│   │   │   ├── environment.tf
│   │   │   ├── service.tf
│   │   │   ├── infrastructure.tf
│   │   │   └── cd_pipeline.tf
│   │   └── outputs.tf
├── github/
│   └── workflows/
│       └── pr-validation.yaml
└── .gitignore