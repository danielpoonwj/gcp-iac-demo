data "google_compute_image" "default" {
  project = "${var.project}"
  family  = "packer-${var.env}-${var.name}"
}

resource "google_compute_instance_template" "default" {
  name_prefix  = "${var.name}-${var.env}-"
  machine_type = "${var.instance_type}"
  region       = "${var.region}"

  tags = ["${var.name}-${var.env}"]

  disk {
    source_image = "${data.google_compute_image.default.self_link}"
    type         = "PERSISTENT"
    disk_size_gb = "${var.disk_size}"
  }

  network_interface {
    subnetwork = "${var.private_subnet_id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "default" {
  project = "${var.project}"
  name    = "${var.name}-${var.env}"

  tcp_health_check = {
    port = "${element(var.named_port, 1)}"
  }
}

resource "google_compute_instance_group_manager" "default" {
  name               = "${var.name}-${var.env}"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  base_instance_name = "${var.name}-${var.env}"
  zone               = "${var.zone}"
  target_size        = "1"

  named_port {
    name = "${element(var.named_port, 0)}"
    port = "${element(var.named_port, 1)}"
  }
}

resource "google_compute_backend_service" "default" {
  project     = "${var.project}"
  name        = "${var.name}-${var.env}"
  port_name   = "${element(var.named_port, 0)}"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.default.instance_group}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}
