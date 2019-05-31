resource "google_compute_subnetwork" "public" {
  project       = "${var.project}"
  name          = "${var.name}-${var.env}"
  ip_cidr_range = "${var.cidr}"
  network       = "${var.vpc_id}"
  region        = "${var.region}"

  private_ip_google_access = false

  lifecycle {
    create_before_destroy = true
  }
}
