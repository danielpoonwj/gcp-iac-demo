output "backend_service_id" {
  value = "${google_compute_backend_service.default.self_link}"
}

output "backend_service_name" {
  value = "${google_compute_backend_service.default.name}"
}
