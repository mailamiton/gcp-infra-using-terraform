#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipelines fail on the first command which fails, not the last one.
set -o pipefail

# --- Script Functions ---

# Function to log informational messages
log() {
  echo "INFO: $1"
}

# Function to log warning messages
warn() {
  echo "WARN: $1"
}

# Creates a file only if it does not already exist.
create_file_if_not_exists() {
  local file_path="$1"
  if [ ! -f "$file_path" ]; then
    log "Creating file: $file_path"
    touch "$file_path"
  else
    warn "File already exists, skipping: $file_path"
  fi
}

# Creates the shared modules structure.
create_modules() {
  log "Processing shared modules..."
  local modules_root_dir="$ROOT_DIR/modules"
  mkdir -p "$modules_root_dir"

  for module in "${MODULES[@]}"; do
    local module_dir="$modules_root_dir/$module"
    mkdir -p "$module_dir"
    create_file_if_not_exists "$module_dir/main.tf"
    create_file_if_not_exists "$module_dir/variables.tf"
    create_file_if_not_exists "$module_dir/outputs.tf"
  done
}

# Creates the team and environment-specific structure.
create_team_envs() {
  log "Processing team environments..."
  for team in "${TEAMS[@]}"; do
    for env in "${ENVS[@]}"; do
      local team_env_dir="$ROOT_DIR/teams/$team/$env"
      log "Setting up structure for $team in $env environment..."
      mkdir -p "$team_env_dir"

      create_file_if_not_exists "$team_env_dir/main.tf"
      create_file_if_not_exists "$team_env_dir/variables.tf"
      create_file_if_not_exists "$team_env_dir/terraform.tfvars"
      create_file_if_not_exists "$team_env_dir/provider.tf"

      # Create backend.tf if it doesn't exist
      local backend_file="$team_env_dir/backend.tf"
      if [ ! -f "$backend_file" ]; then
        log "Creating backend configuration: $backend_file"
        local backend_prefix="teams/$team/$env"
        cat <<EOF > "$backend_file"
terraform {
  backend "gcs" {
    # This is the standard approach where the bucket name is known and consistent.
    bucket = "$TF_STATE_BUCKET"
    prefix = "$backend_prefix"

    # For a more flexible approach (e.g., using different buckets per environment),
    # you could comment out the 'bucket' line above and supply it during initialization:
    # terraform init -backend-config="bucket=my-dev-bucket"
    # terraform init -backend-config="bucket=my-prod-bucket"
  }
}
EOF
      else
        warn "Backend file already exists, skipping: $backend_file"
      fi
    done
  done
}

# Creates the global resources structure.
create_global_dirs() {
  log "Processing global resources directory..."
  local global_dir="$ROOT_DIR/global/org-policies"
  mkdir -p "$global_dir"
  create_file_if_not_exists "$global_dir/main.tf"
}

# --- Main Execution ---
main() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local config_file="$script_dir/setup-config.sh"

  if [ ! -f "$config_file" ]; then
    echo "ERROR: Configuration file not found at $config_file. Please create it."
    exit 1
  fi

  # Source the configuration
  # shellcheck source=./setup-config.sh
  source "$config_file"

  log "📁 Verifying/Creating Terraform directory structure based on configuration..."
  create_modules
  create_team_envs
  create_global_dirs

  log "✅ Terraform folder structure is ready under: $ROOT_DIR"
}

# Run the main function
main "$@"
