variable "project" {}

variable "env" {}

variable "region" {}

variable "zone" {}

variable "vpc_id" {}

variable "private_subnet_id" {}

variable "instance_type" {}

variable "disk_size" {}

variable "named_port" {
  type = "list"
}
