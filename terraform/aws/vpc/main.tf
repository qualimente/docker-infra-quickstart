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

resource "aws_eip" "nat" {
  count = "3"
  vpc   = true
  depends_on    = ["module.dmz_subnet"]
}

resource "aws_nat_gateway" "main" {
  count         = "3"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(module.dmz_subnet.subnet_ids, count.index)}"
  depends_on    = ["aws_internet_gateway.main", "module.dmz_subnet"]
}

module "dmz_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_public_subnet"

  name   = "${var.environment}-dmz"

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

module "app_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_private_subnet_nat_gateway"

  name   = "${var.environment}-app"

  cidrs = [
      "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 0)), 4, 1)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 1)), 4, 1)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 2)), 4, 1)}"
    ]

  azs    = "${keys(var.az_cidr_blocks)}"

  vpc_id = "${aws_vpc.main.id}"

  nat_gateways_count = "1"
  public_subnet_ids  = "${module.dmz_subnet.subnet_ids}"

}

module "data_subnet" {
  source = "github.com/terraform-community-modules/tf_aws_private_subnet_nat_gateway"

  name   = "${var.environment}-data"

  cidrs = [
      "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 0)), 6, 2)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 1)), 6, 2)}"
      , "${cidrsubnet(lookup(var.az_cidr_blocks, element(keys(var.az_cidr_blocks), 2)), 6, 2)}"
    ]

  azs    = "${keys(var.az_cidr_blocks)}"

  vpc_id = "${aws_vpc.main.id}"

  nat_gateways_count = "1"
  public_subnet_ids  = "${module.dmz_subnet.subnet_ids}"

}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.main.default_security_group_id}"
}

