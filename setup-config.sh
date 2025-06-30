#!/bin/bash

# --- Configuration for Terraform Directory Structure ---

# The root directory for the Terraform setup.
# All other directories will be created inside this one.
export ROOT_DIR="terraform"

# The name of the GCS bucket used for storing Terraform state files.
# This will be used in the backend.tf configuration.
export TF_STATE_BUCKET="terra-infra-state-bucket"

# An array of team names.
# A directory will be created for each team under 'teams/'.
export TEAMS=("team-ops" "team-data")

# An array of environment names.
# Subdirectories for each environment will be created under each team's directory.
export ENVS=("dev" "prod")

# An array of shared module names.
# A directory for each module will be created under 'modules/'.
export MODULES=("network" "compute" "gke" "project-factory")