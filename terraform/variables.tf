variable "harness_account_id" {
  description = "Harness account identifier"
  type        = string
}

variable "harness_api_key" {
  description = "Harness Platform API key"
  type        = string
  sensitive   = true
}
variable "project_id" {
  description = "Harness project identifier"
  type        = string
  default     = "java-microservice"
}

variable "org_id" {
  description = "Harness organization identifier"
  type        = string
  default     = "default"
}

variable "github_repo" {
  description = "GitHub repository in format: owner/repo"
  type        = string
}

variable "github_connector_id" {
  description = "Identifier for the GitHub connector"
  type        = string
  default     = "github-conn"
}

variable "k8s_connector_id" {
  description = "Identifier for the Kubernetes connector"
  type        = string
  default     = "k8s-conn"
}

variable "namespace" {
  description = "Kubernetes namespace for deployments"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "cluster_region" {
  description = "Cloud region where the cluster is located"
  type        = string
}

variable "cluster_project_id" {
  description = "Cloud provider project ID"
  type        = string
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
  default     = "k8s"
}