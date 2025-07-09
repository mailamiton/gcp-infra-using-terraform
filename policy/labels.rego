package main

required_labels = {"application", "team", "environment"}

deny[msg] {
  resource := input.resource_changes[_].change.after
  resource.labels
  missing := required_labels - {k | resource.labels[k]}
  count(missing) > 0
  msg = sprintf("Resource missing required labels: %v", [missing])
}
