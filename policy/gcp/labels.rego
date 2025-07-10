package main

required_labels = {"application", "team", "environment"}

deny[msg] {
  rc := input.resource_changes[_]
  after := rc.change.after
  after.labels

  missing := required_labels - {k | after.labels[k]}
  count(missing) > 0

  msg := sprintf("Resource '%s' missing required labels: %v", [rc.address, missing])
}
