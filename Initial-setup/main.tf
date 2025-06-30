provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file(var.credentials_file)
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

  # Inject GCP SA key via metadata (example) OR manually preload the key into the VM
  # echo "$GCP_SA_JSON" > terraform-sa.json (example if passed as startup variable)

  # Create Docker Compose file
  cat << 'DOCKER' > docker-compose.yml
  version: "3"
  services:
    atlantis:
      image: runatlantis/atlantis
      container_name: atlantis
      ports:
        - "4141:4141"
      environment:
        - ATLANTIS_GH_USER=<github-username>
        - ATLANTIS_GH_TOKEN=<personal-access-token>
        - ATLANTIS_GH_WEBHOOK_SECRET=<random-secret>
        - ATLANTIS_REPO_ALLOWLIST=github.com/<your-org>/<repo>
        - 'ATLANTIS_REPO_CONFIG_JSON={"repos": [{"id": "/.*/", "allowed_overrides": ["workflow"], "allow_custom_workflows": true}]}'
        - ATLANTIS_PORT=4141
      volumes:
        - ./repos:/home/atlantis/repos
        - ./terraform-sa.json:/home/atlantis/terraform-sa.json
      restart: unless-stopped
  DOCKER

  # Place your GCP SA file in the same dir if you use prebuilt image or metadata/scripts
  # For test, write fake one to avoid docker crash (remove in prod)
  echo '{}' > terraform-sa.json

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