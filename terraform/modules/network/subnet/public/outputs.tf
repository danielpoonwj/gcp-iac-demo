output "subnet_id" {
  value = "${google_compute_subnetwork.public.self_link}"
}
