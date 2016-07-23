# Define a Virtual Private Cloud and required networks to host the infrastructure

variable "name" { default = "docker-infra-quickstart" }
variable "vpc_cidr" { default = "10.42.0.0/16" }
variable "region" {}
variable "availability_zones"  {  default = "a,b,c" }

# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
variable "cidr_blocks" {
  default = {
    az0 = "10.42.0.0/18"
    az1 = "10.42.64.0/18"
    az2 = "10.42.128.0/18"
    #az3 = "10.42.192.0/18" # could add a fourth az, if region permits
  }
}


resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
    CreatedBy = "terraform"
  }
}

resource "aws_subnet" "dmz" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${cidrsubnet(lookup(var.cidr_blocks, concat("az", count.index)), 6, 0)}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
  tags {
    Name = "${concat("az", count.index)}-dmz"
  }
}

resource "aws_subnet" "app" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${cidrsubnet(lookup(var.cidr_blocks, concat("az", count.index)), 6, 1)}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
  tags {
    Name = "${concat("az", count.index)}-app"
  }
}

resource "aws_subnet" "mgmt" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${cidrsubnet(lookup(var.cidr_blocks, concat("az", count.index)), 6, 2)}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
  tags {
    Name = "${concat("az", count.index)}-mgmt"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "availability_zones" {
  value = "${join(",",aws_subnet.dmz.*.availability_zone)}"
}

