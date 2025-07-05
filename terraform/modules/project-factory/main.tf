# This resource uses a random suffix to help ensure the project ID is globally unique.
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# The core resource for creating a new Google Cloud project.
resource "google_project" "project" {
  name            = var.project_name
  project_id      = "${var.project_name_prefix}-${random_string.suffix.result}"
  billing_account = var.billing_account_id
  folder_id       = var.folder_id

  labels = var.labels
}

# This resource enables the specified APIs on the newly created project.
# It uses a for_each loop to iterate over the list of APIs provided.
resource "google_project_service" "apis" {
  # Wait for the project to be created before trying to enable APIs.
  depends_on = [google_project.project]

  for_each = toset(var.apis_to_enable)

  project = google_project.project.project_id
  service = each.key

  # This prevents Terraform from trying to disable the APIs when the project is destroyed.
  # It's a common practice as disabling APIs can sometimes cause issues.
  disable_on_destroy = false
}