resource "google_compute_router" "router" {
  project = "${var.project}"
  name    = "${var.name}-router"
  region  = "${var.region}"
  network = "${var.vpc_id}"

  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "address" {
  name   = "${var.name}-external-address"
  region = "${var.region}"
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-nat"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${google_compute_address.address.self_link}"]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "${var.private_subnet_id}"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
