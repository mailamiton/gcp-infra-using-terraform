terraform {
  backend "gcs" {
    # This is the standard approach where the bucket name is known and consistent.
    bucket = "terra-infra-state-bucket"
    prefix = "teams/team-ops/dev"

    # For a more flexible approach (e.g., using different buckets per environment),
    # you could comment out the 'bucket' line above and supply it during initialization:
    # terraform init -backend-config="bucket=my-dev-bucket"
    # terraform init -backend-config="bucket=my-prod-bucket"
  }
}
