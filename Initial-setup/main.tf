provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "terra-infra-state-bucket"
    prefix = "atlantis/setup"
  }
}

data "google_compute_network" "default" {
  name = "default"
}


resource "google_compute_instance" "atlantis-instance" {
  name         = "atlantis-instance"
  machine_type = var.instance_type
  zone         = var.availability_zone_names[0]

  boot_disk {
    initialize_params {
      image = var.image_id
    }
  }
  service_account {
    email  = var.terraform_service_account
    scopes = ["cloud-platform"]
  }
  network_interface {
    network = data.google_compute_network.default.self_link
    access_config {
        nat_ip = var.elastic_ip // Auto-assign a public IP address if this is null
    }
  }
  tags = ["atlantis-machine"]

  metadata_startup_script = <<-EOF
  #!/bin/bash
  set -euo pipefail

  # Avoid interactive prompts
  export DEBIAN_FRONTEND=noninteractive

  # --- Update & install core packages ---
  apt-get update -y
  apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

  # --- Install Docker from official repo ---
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl enable docker
  systemctl start docker

 # --- Install Terraform v${var.atlantis_terraform_version} ---
  curl -sSLo terraform.zip "https://releases.hashicorp.com/terraform/${var.atlantis_terraform_version}/terraform_${var.atlantis_terraform_version}_linux_amd64.zip"
  unzip terraform.zip -d /usr/local/bin
  chmod +x /usr/local/bin/terraform
  rm terraform.zip

  # Print versions to verify
  terraform version
  docker --version
  docker compose version
EOF


}


resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network =  data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
    allow {
    protocol = "tcp"
    ports    = ["80"]
  }
    allow {
    protocol = "tcp"
    ports    = ["4141"]
  }
  target_tags = ["atlantis-machine"]
  source_ranges = ["0.0.0.0/0"] // allow traffic from anywhere
}