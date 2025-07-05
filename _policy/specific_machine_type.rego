package main

deny[msg] {
  resource := input.resource_changes[_].change.after
  resource.machine_type
  not startswith(resource.machine_type, "n2-")
  msg = sprintf("Only n2-* machine types are allowed. Found: %s", [resource.machine_type])
}
