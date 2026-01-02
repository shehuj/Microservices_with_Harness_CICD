resource "harness_platform_triggers" "pr_trigger" {
  identifier = "github_pr_trigger"
  name       = "GitHub PR Trigger"
  org_id     = var.org_id
  project_id = var.project_id
  target_id  = harness_platform_pipeline.ci_pipeline.identifier

  yaml = <<-EOT
    trigger:
      name: GitHub PR Trigger
      identifier: github_pr_trigger
      enabled: true
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      pipelineIdentifier: ${harness_platform_pipeline.ci_pipeline.identifier}
      source:
        type: Webhook
        spec:
          type: Github
          spec:
            type: PullRequest
            spec:
              connectorRef: ${var.github_connector_id}
              autoAbortPreviousExecutions: false
              payloadConditions:
                - key: targetBranch
                  operator: Equals
                  value: ${var.default_branch}
              headerConditions: []
              repoName: ${var.github_repo}
              actions:
                - Open
                - Reopen
                - Synchronize
  EOT
}