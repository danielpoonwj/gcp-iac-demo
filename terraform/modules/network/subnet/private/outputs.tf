output "subnet_id" {
  value = "${google_compute_subnetwork.private.self_link}"
}
