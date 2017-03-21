# Define a Virtual Private Cloud and required networks to host the infrastructure

variable "name" { default = "docker-infra-quickstart" }
variable "environment" { }
variable "cidr" { default = "10.42.0.0/16" }
variable "region" {}
variable "az_cidr_blocks" {
  type = "map"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
    CreatedBy = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}


module "dmz_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_public_subnet"

  name   = "${var.name}-dmz"

  cidrs = [
      "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 0)), 6, 0)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 1)), 6, 0)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 2)), 6, 0)}"
    ]

  azs    = "${keys(var.az_cidr_blocks)}"

  vpc_id = "${aws_vpc.main.id}"
  igw_id = "${aws_internet_gateway.main.id}"

  tags {
      CreatedBy = "terraform"
      Environment = "${var.environment}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.main.default_security_group_id}"
}

