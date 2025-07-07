package main

deny[msg] {
  input.resource_changes[_].change.after.email == "default"
  msg = "Using default service account is not allowed"
}