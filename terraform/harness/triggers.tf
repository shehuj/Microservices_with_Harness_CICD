resource "harness_platform_trigger" "pr_trigger" {
  name        = "GitHub PR Trigger"
  identifier  = "github_pr_trigger"
  org_id      = var.org_id
  project_id  = var.project_id
  pipeline_id = harness_platform_pipeline.ci_pipeline.identifier

  github {
    spec {
      type = "PullRequest"
      spec {
        repo_name     = var.github_repo
        actions       = ["opened","reopened","synchronize"]
        target_branch = "main"
      }
    }
  }
}