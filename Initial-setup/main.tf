provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file(var.credentials_file)
}

data "google_compute_network" "default" {
  name = "default"
}


resource "google_storage_bucket" "my_bucket" {
  name     = "${var.project_id}-infra-state-bucket"
  location = var.region
}

resource "google_compute_instance" "atlantis-instance" {
  name         = "atlantis-instance"
  machine_type = var.instance_type // 2 vCPUs, 2 GB RAM
  zone         = var.availability_zone_names[0]

  boot_disk {
    initialize_params {
      image = var.image_id
    }
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
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    udo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
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