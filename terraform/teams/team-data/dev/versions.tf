terraform {
  required_version = "= 1.8.4" # use an exact version if you're enforcing consistency

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45.0"  # use latest stable 5.x like 5.45.2 if you want to allow patches
    }
  }
}
