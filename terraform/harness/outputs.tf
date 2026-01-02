output "ci_pipeline_id" {
  value = harness_platform_pipeline.ci_pipeline.id
}

output "github_trigger_id" {
  value = harness_platform_trigger.pr_trigger.id
}

output "cd_pipeline_id" {
  value = harness_platform_pipeline.cd_pipeline.id
}