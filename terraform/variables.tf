variable "harness_account_id" {
  description = "Harness account identifier"
  type        = string
  default     = "6ag5x-oJQWerhSczUHXcaw"
}

variable "harness_api_key" {
  description = "Harness Platform API key"
  type        = string
  sensitive   = true
}
variable "project_id" {
  description = "Harness project identifier"
  type        = string
  default     = "belenshi"
}

variable "org_id" {
  description = "Harness organization identifier"
  type        = string
  default     = "default"
}

variable "github_repo" {
  description = "GitHub repository in format: owner/repo"
  type        = string
  default     = "shehuj/Microservices_with_Harness_CICD"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$", var.github_repo))
    error_message = "GitHub repository must be in format 'owner/repo'."
  }
}

variable "github_connector_id" {
  description = "Identifier for the GitHub connector"
  type        = string
  default     = "github_conn"
}

variable "k8s_connector_id" {
  description = "Identifier for the Kubernetes connector"
  type        = string
  default     = "k8s_conn"
}

variable "namespace" {
  description = "Kubernetes namespace for deployments"
  type        = string
  default     = "harness"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "Namespace must be a valid Kubernetes namespace name (lowercase alphanumeric and hyphens only)."
  }
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "cart"
}

variable "cluster_region" {
  description = "Cloud region where the cluster is located"
  type        = string
  default     = "us-east-1"
}

variable "cluster_project_id" {
  description = "Cloud provider project ID"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name of the microservice"
  type        = string
  default     = "java-microservice"
}

variable "docker_registry" {
  description = "Docker registry URL (e.g., docker.io, ghcr.io, gcr.io)"
  type        = string
  default     = "docker.io"
}

variable "default_branch" {
  description = "Default git branch for pipelines"
  type        = string
  default     = "main"
}

variable "delegate_selector" {
  description = "Harness delegate selector tag"
  type        = string
  default     = "helm-delegate"
}

variable "docker_connector_id" {
  description = "Identifier for the Docker registry connector"
  type        = string
  default     = "docker_conn"
}

variable "docker_registry_url" {
  description = "Docker registry URL (e.g., https://index.docker.io/v1/)"
  type        = string
  default     = "https://index.docker.io/v1/"
}

variable "docker_username" {
  description = "Docker registry username"
  type        = string
  default     = "captcloud01"
}
# Delegate Configuration
variable "harness_delegate_token" {
  description = "Harness delegate token for authentication (optional - only needed if deploying delegate via Terraform)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "delegate_name" {
  description = "Name of the Harness delegate"
  type        = string
  default     = "harness-delegate"
}

variable "delegate_replicas" {
  description = "Number of delegate replicas"
  type        = number
  default     = 1
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "deploy_delegate" {
  description = "Whether to deploy delegate via Terraform (set to false to skip delegate deployment)"
  type        = bool
  default     = true
}

variable "harness_manager_endpoint" {
  description = "Harness manager endpoint (use 'gratis' for free tier, or your specific endpoint)"
  type        = string
  default     = "https://app.harness.io/gratis"
}
