# Harness File Store Resources
# Upload K8s manifest files to Harness File Store

# Create folder for K8s manifests
resource "harness_platform_file_store_folder" "k8s" {
  org_id            = var.org_id
  project_id        = var.project_id
  identifier        = "k8s"
  name              = "k8s"
  description       = "Kubernetes manifest files"
  parent_identifier = "Root"
}

# Upload deployment.yaml to Harness File Store
resource "harness_platform_file_store_file" "deployment_yaml" {
  org_id            = var.org_id
  project_id        = var.project_id
  identifier        = "deployment_yaml"
  name              = "deployment.yaml"
  description       = "Kubernetes Deployment manifest for Java microservice"
  tags              = ["k8s", "deployment"]
  parent_identifier = harness_platform_file_store_folder.k8s.identifier
  file_content_path = "${path.module}/../k8s/deployment.yaml"
  file_usage        = "MANIFEST_FILE"
  mime_type         = "text/yaml"
}

# Upload service.yaml to Harness File Store
resource "harness_platform_file_store_file" "service_yaml" {
  org_id            = var.org_id
  project_id        = var.project_id
  identifier        = "service_yaml"
  name              = "service.yaml"
  description       = "Kubernetes Service manifest for Java microservice"
  tags              = ["k8s", "service"]
  parent_identifier = harness_platform_file_store_folder.k8s.identifier
  file_content_path = "${path.module}/../k8s/service.yaml"
  file_usage        = "MANIFEST_FILE"
  mime_type         = "text/yaml"
}
