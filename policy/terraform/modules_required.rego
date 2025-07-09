package main

deny[msg] {
  input.resource_blocks[i]
  msg := "Direct resource block detected: use Terraform modules instead"
}
