terraform {
  required_version = ">= 1.0.0"

  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.38"
    }
  }
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_account_id
  platform_api_key = var.harness_api_key
}