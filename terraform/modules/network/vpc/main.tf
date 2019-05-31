resource "google_compute_network" "vpc" {
  project                 = "${var.project}"
  name                    = "${var.name}-${var.env}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}
