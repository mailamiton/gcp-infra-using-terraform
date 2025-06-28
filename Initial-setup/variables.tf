variable "project_id" {}
variable "credentials_file" {}
variable "instance_type" {}
variable "elastic_ip" {
  type = string
  default =""
}
variable "image_id" {
  type = string
  default = "ubuntu-2204-lts" # Ubuntu 22.04 LTS (HVM)
}
variable "region" {
    type = string
    default = "us-central1"
}
variable "availability_zone_names" {
  type    = list(string)
  default = ["us-central1-a"]
}