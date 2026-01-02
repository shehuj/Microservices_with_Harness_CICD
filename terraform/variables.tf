variable "harness_account_id" {}
variable "harness_api_key" {}
variable "project_id" {}
variable "org_id" {}
variable "github_repo" {}
variable "github_connector_id" {}
variable "k8s_connector_id" {}
variable "namespace" {
 # default = "default"
}
variable "cluster_name" {}
variable "cluster_region" {}
variable "cluster_project_id" {}
variable "service_name" {}
variable "docker_registry" {
  description = "Docker registry URL (e.g., docker.io, ghcr.io)"
  default     = "docker.io"
}