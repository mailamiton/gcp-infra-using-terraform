variable "project_name" {
  type        = string
  description = "The display name of the project."
}

variable "project_name_prefix" {
  type        = string
  description = "The prefix for the project ID. A random 4-character suffix will be appended."
}

variable "billing_account_id" {
  type        = string
  description = "The ID of the billing account to associate the project with."
}

variable "folder_id" {
  type        = string
  description = "The ID of the folder to create the project in."
  default     = null
}

variable "apis_to_enable" {
  type        = list(string)
  description = "A list of Google Cloud APIs to enable on the project."
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

variable "labels" {
  type        = map(string)
  description = "A map of labels to apply to the project."
  default     = {}
}