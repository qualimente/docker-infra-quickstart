# Define a Virtual Private Cloud and required networks to host the infrastructure

variable "name" { default = "docker-infra-quickstart" }
variable "cidr" { default = "10.42.0.0/16" }
variable "region" {}

resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
    CreatedBy = "terraform"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.main.default_security_group_id}"
}

