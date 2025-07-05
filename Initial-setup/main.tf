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

  # Install Docker
  apt update
  apt install -y docker.io curl

  systemctl enable docker
  systemctl start docker

  # Install Docker Compose
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  docker-compose --version

  # Install nginx (optional, reverse proxy later)
  apt install -y nginx
  systemctl enable nginx
  systemctl start nginx

  # Create working dir
  mkdir -p /opt/atlantis/repos
  cd /opt/atlantis

  # Create Docker Compose file
  cat << 'DOCKER' > docker-compose.yml
  services:
    atlantis:
      image: runatlantis/atlantis:latest
      container_name: atlantis
      network_mode: "host"
      environment:
        - ATLANTIS_GH_USER=<github-username>
        - ATLANTIS_GH_TOKEN=<personal-access-token>
        - ATLANTIS_GH_WEBHOOK_SECRET=<random-secret>
        - ATLANTIS_REPO_ALLOWLIST=github.com/<your-org>/<repo>
      volumes:
        - ./repos:/home/atlantis/repos
        - ./atlantis.yaml:/atlantis/repos.yaml
        - ./config.yaml:/etc/atlantis/config.yaml:ro
      command: ["server", "--config", "/etc/atlantis/config.yaml"]
      restart: unless-stopped
  DOCKER

  #  Atlantis server-side config used to define workflow
  cat << 'CONFIG_FILE_WEBHOOK' > config.yaml
  repos:
  - id: /.*/
    workflow: conftest
    allowed_overrides: [workflow, apply_requirements]

  workflows:
    conftest:
      plan:
        steps:
          - init
          - plan
          - show
          - run: conftest test --all-namespaces -p policy/ -
      apply:
        steps:
          - apply
  CONFIG_FILE_WEBHOOK

  # Start Atlantis
  docker-compose up -d
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