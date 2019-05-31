module "backend_service" {
  source = "../backend_service"

  project = "${var.project}"
  name    = "jenkins"
  env     = "${var.env}"
  region  = "${var.region}"

  vpc_id            = "${var.vpc_id}"
  private_subnet_id = "${var.private_subnet_id}"

  zone          = "${var.zone}"
  instance_type = "${var.instance_type}"
  disk_size     = "${var.disk_size}"
  named_port    = "${var.named_port}"
}

# LOAD BALANCER
resource "google_compute_global_address" "jenkins" {
  project = "${var.project}"
  name    = "jenkins-${var.env}"
}

resource "google_compute_target_http_proxy" "http" {
  project = "${var.project}"
  name    = "jenkins-${var.env}"
  url_map = "${google_compute_url_map.jenkins.self_link}"
}

resource "google_compute_url_map" "jenkins" {
  project = "${var.project}"
  name    = "jenkins-${var.env}"

  default_service = "${module.backend_service.backend_service_id}"
}

resource "google_compute_global_forwarding_rule" "http" {
  project    = "${var.project}"
  name       = "jenkins-${var.env}"
  target     = "${google_compute_target_http_proxy.http.self_link}"
  ip_address = "${google_compute_global_address.jenkins.address}"
  port_range = "80"
}

# https://cloud.google.com/compute/docs/load-balancing/network/#firewall_rules_and_network_load_balancing
resource "google_compute_firewall" "allow_lb_ingress" {
  project       = "${var.project}"
  name          = "jenkins-${var.env}-allow-lb-ingress"
  description   = "Allow TCP ingress from Load Balancer to Jenkins"
  network       = "${var.vpc_id}"
  source_ranges = ["130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]

  priority = 980

  target_tags = ["${module.backend_service.backend_service_name}"]

  allow {
    protocol = "tcp"
    ports    = ["${element(var.named_port, 1)}"]
  }
}
