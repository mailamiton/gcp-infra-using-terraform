variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project"
}

variable "region" {
  type        = string
  description = "The region where the resources will be created"
}

variable "image_id" {
  type        = string
  description = "The ID of the image to use"
}

variable "elastic_ip" {
  type        = string
  description = "The public IP address to assign to the instance"
}

variable "instance_type" {
  type        = string
  description = "The type of instance to create"
}

variable "availability_zone_names" {
  type        = list(string)
  description = "The list of availability zones"
}

variable "terraform_service_account" {
  type        = string
  description = "The name of the Terraform service account"
}

variable "atlantis_terraform_version" {
  description = "The version of Terraform to install on the Atlantis server."
  type        = string
  default     = "1.8.4"
}

variable "state_bucket_name" {
  type        = string
  description = "The name of the state bucket"
}