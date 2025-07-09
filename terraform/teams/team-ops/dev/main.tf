module "external-data-landing-zone" {
  # Use a relative path to call the shared module
  source = "../../../modules/project-factory"

  project_name         = "ext-data-land"
  project_name_prefix  = "data-team"
  billing_account_id   = "019E58-6F6589-65814F" # <-- Replace with your actual Billing Account ID
  folder_id            = "123456789012"         # <-- Replace with your actual Folder ID

  # Override the default list of APIs to include the GKE API
  apis_to_enable = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com"
  ]

  labels = {
    environment = "dev"
    team        = "ops"
    application = "analytics"
  }
}



# Define multiple folders to archive and upload
locals {
  atlantis_archives = {
    policy   = "${path.module}/"
  }
}

# Dynamically create archive files
data "archive_file" "zips" {
  for_each    = local.atlantis_archives
  type        = "zip"
  source_dir  = each.value
  output_path = "${path.module}/tmp/${each.key}.zip"
}

# Upload each archive to GCS
resource "google_storage_bucket_object" "archives" {
  for_each = data.archive_file.zips

  name   = "atlantis_metadata/${each.key}.zip"
  bucket = "test"
  source = each.value.output_path
}
