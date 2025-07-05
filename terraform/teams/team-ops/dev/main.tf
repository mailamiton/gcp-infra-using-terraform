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

  # labels = {
  #   environment = "dev"
  #   team        = "ops"
  #   application = "analytics"
  # }
}
