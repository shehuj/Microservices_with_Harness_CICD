# Terraform Backend Configuration
#
# This file configures where Terraform stores its state file.
# Using a remote backend is recommended for team collaboration and CI/CD.
#
# IMPORTANT: Uncomment and configure ONE of the backend options below.
# Do NOT use multiple backends simultaneously.

# Option 1: S3 Backend (AWS)
# Recommended for AWS environments
terraform {
  backend "s3" {
    bucket         = "ec2-shutdown-lambda-bucket"
    key            = "harness-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
#   use_lockfile = yes
    dynamodb_table = "dyning_table"
  }
}

# Option 2: GCS Backend (Google Cloud)
# Recommended for GCP environments
# terraform {
#   backend "gcs" {
#     bucket  = "my-terraform-state-bucket"
#     prefix  = "harness-cicd"
#   }
# }

# Option 3: Azure Backend (Azure)
# Recommended for Azure environments
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstatestorage"
#     container_name       = "tfstate"
#     key                  = "harness-cicd.tfstate"
#   }
# }

# Option 4: Terraform Cloud
# Recommended for using Terraform Cloud/Enterprise
# terraform {
#   backend "remote" {
#     organization = "my-org"
#     workspaces {
#       name = "harness-cicd"
#     }
#   }
# }

# Default: Local Backend
# If no backend is configured above, Terraform uses local state.
# This is NOT recommended for production or team environments.
# The state file will be stored locally as terraform.tfstate
