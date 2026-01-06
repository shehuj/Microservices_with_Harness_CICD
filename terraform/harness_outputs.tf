# Pipeline Outputs
output "ci_pipeline_id" {
  description = "ID of the CI pipeline"
  value       = harness_platform_pipeline.ci_pipeline.id
}

output "ci_pipeline_identifier" {
  description = "Identifier of the CI pipeline"
  value       = harness_platform_pipeline.ci_pipeline.identifier
}

output "cd_pipeline_id" {
  description = "ID of the CD pipeline"
  value       = harness_platform_pipeline.cd_pipeline.id
}

output "cd_pipeline_identifier" {
  description = "Identifier of the CD pipeline"
  value       = harness_platform_pipeline.cd_pipeline.identifier
}

# Connector Outputs
output "github_connector_id" {
  description = "ID of the GitHub connector"
  value       = harness_platform_connector_github.github.id
}

output "github_connector_identifier" {
  description = "Identifier of the GitHub connector"
  value       = harness_platform_connector_github.github.identifier
}

output "k8s_connector_id" {
  description = "ID of the Kubernetes connector"
  value       = harness_platform_connector_kubernetes.k8s.id
}

output "k8s_connector_identifier" {
  description = "Identifier of the Kubernetes connector"
  value       = harness_platform_connector_kubernetes.k8s.identifier
}

output "docker_connector_id" {
  description = "ID of the Docker connector"
  value       = harness_platform_connector_docker.docker_registry.id
}

output "docker_connector_identifier" {
  description = "Identifier of the Docker connector"
  value       = harness_platform_connector_docker.docker_registry.identifier
}

# Trigger Outputs
output "github_trigger_id" {
  description = "ID of the GitHub PR trigger"
  value       = harness_platform_triggers.pr_trigger.id
}

output "github_trigger_identifier" {
  description = "Identifier of the GitHub PR trigger"
  value       = harness_platform_triggers.pr_trigger.identifier
}

# Secret Outputs
output "github_secret_id" {
  description = "ID of the GitHub PAT secret"
  value       = harness_platform_secret_text.github_pat.id
}

output "registry_secret_id" {
  description = "ID of the Docker registry password secret"
  value       = harness_platform_secret_text.docker_registry_password.id
}

# CD Resource Outputs
output "service_id" {
  description = "ID of the Harness service"
  value       = harness_platform_service.service.id
}

output "service_identifier" {
  description = "Identifier of the Harness service"
  value       = harness_platform_service.service.identifier
}

output "environment_id" {
  description = "ID of the staging environment"
  value       = harness_platform_environment.env.id
}

output "environment_identifier" {
  description = "Identifier of the staging environment"
  value       = harness_platform_environment.env.identifier
}

output "infrastructure_id" {
  description = "ID of the infrastructure definition"
  value       = harness_platform_infrastructure.staging_infra.id
}

output "infrastructure_identifier" {
  description = "Identifier of the infrastructure definition"
  value       = harness_platform_infrastructure.staging_infra.identifier
}