provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  version = "~> 2.7"
}

data "terraform_remote_state" "network" {
  backend = "gcs"

  config {
    bucket = "gcp-demo-terraform-state-bucket"
    prefix = "gcp/dev/network"
    region = "asia-southeast1"
  }
}

module "jenkins" {
  source = "../../modules/jenkins"

  project = "${var.project}"
  env     = "${var.env}"
  region  = "${var.region}"
  zone    = "${var.zone}"

  vpc_id            = "${data.terraform_remote_state.network.vpc_id}"
  private_subnet_id = "${data.terraform_remote_state.network.private_subnet_id}"

  instance_type = "${var.instance_type}"
  disk_size     = "${var.disk_size}"
  named_port    = "${var.named_port}"
}
