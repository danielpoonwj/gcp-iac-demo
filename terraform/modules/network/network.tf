module "vpc" {
  source = "./vpc"

  project = "${var.project}"
  name    = "${var.name}-vpc"
  env     = "${var.env}"
}

module "public_subnet" {
  source = "./subnet/public"

  project = "${var.project}"
  name    = "${var.name}-public"
  env     = "${var.env}"
  vpc_id  = "${module.vpc.vpc_id}"
  cidr    = "${var.public_cidr}"
  region  = "${var.region}"
}

module "private_subnet" {
  source = "./subnet/private"

  project = "${var.project}"
  name    = "${var.name}-private"
  env     = "${var.env}"
  vpc_id  = "${module.vpc.vpc_id}"
  cidr    = "${var.private_cidr}"
  region  = "${var.region}"
}

module "nat_gateway" {
  source = "./nat"

  project           = "${var.project}"
  name              = "${var.name}-private"
  env               = "${var.env}"
  vpc_id            = "${module.vpc.vpc_id}"
  region            = "${var.region}"
  private_subnet_id = "${module.private_subnet.subnet_id}"
}
