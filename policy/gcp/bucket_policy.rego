package main

deny[msg] {
  input.resource_changes[_].change.after.bucket_policy_only.enabled == false
  msg = "GCS bucket must have bucket policy only mode enabled"
}
