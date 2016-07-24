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

# Define 3 availability zones
module "az0" {
  source ="../az"
  vpc_id = "${aws_vpc.main.id}"
  az_id = "${var.region}a"
  az_cidr = "10.42.0.0/18"
}

module "az1" {
  source ="../az"
  vpc_id = "${aws_vpc.main.id}"
  az_id = "${var.region}b"
  az_cidr = "10.42.64.0/18"
}

module "az2" {
  source ="../az"
  vpc_id = "${aws_vpc.main.id}"
  az_id = "${var.region}c"
  az_cidr = "10.42.128.0/18"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

