# Define a Virtual Private Cloud and required networks to host the infrastructure

variable "name" {default = "docker-infra-quickstart"}
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "region" {}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
    CreatedBy = "terraform"
  }
}
