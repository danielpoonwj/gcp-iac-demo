output "lb_ip" {
  value = "${google_compute_global_address.jenkins.address}"
}
