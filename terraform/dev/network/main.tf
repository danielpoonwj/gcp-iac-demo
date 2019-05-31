provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  version = "~> 2.7"
}

module "network" {
  source = "../../modules/network"

  project = "${var.project}"
  name    = "${var.name}"
  env     = "${var.env}"
  region  = "${var.region}"

  private_cidr = "${var.private_cidr}"
  public_cidr  = "${var.public_cidr}"
}
