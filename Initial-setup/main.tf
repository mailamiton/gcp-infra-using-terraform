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
  #! /bin/bash
  # Exit on any error
  set -e

  # --- Install Dependencies ---
  apt update
  # Install Git, Docker, and Curl
  apt install -y git docker.io curl
  systemctl enable docker
  systemctl start docker

  # Install Docker Compose v1 (as per original script)
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
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