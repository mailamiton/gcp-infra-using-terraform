output "project_id" {
  description = "The unique ID of the newly created project."
  value       = google_project.project.project_id
}

output "project_number" {
  description = "The number of the newly created project."
  value       = google_project.project.number
}

output "project_name" {
  description = "The display name of the newly created project."
  value       = google_project.project.name
}