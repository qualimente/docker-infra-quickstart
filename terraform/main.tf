provider "aws" {
  region = "${var.region}"
}

variable "region" {default = "us-west-2"}
variable "name" {default = "docker-infra-quickstart"}

# Define CIDR blocks for the VPC and Availability Zones within the VPC
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
# A key network design goal is to enable the AZ to a significant number of c-blocks to support network segmentation
# Providing a /18 network to the AZ enables further division of up to 64 c-block-sized subnets
variable "vpc_cidr" {default = "10.42.0.0/16"}
variable "cidr_blocks" {
  default = {
    az0 = "10.42.0.0/18"
    az1 = "10.42.64.0/18"
    az2 = "10.42.128.0/18"
    #az3 = "10.42.192.0/18" # could add a fourth az, if region permits
  }
}

module "vpc" {
  source ="./aws/vpc"
  name = "${var.name}"
  region = "${var.region}"
  cidr = "10.42.0.0/16"
}

module "keypairs" {
  source ="./aws/keypairs"
}

# Define 3 availability zones
module "az0" {
  source ="./aws/az"
  region = "${var.region}"
  vpc_id = "${module.vpc.vpc_id}"
  az_id = "${var.region}a"
  az_cidr = "${lookup(var.cidr_blocks, "az0")}"

  default_security_group_id = "${module.vpc.default_security_group_id}"
}

module "az1" {
  source ="./aws/az"
  region = "${var.region}"
  vpc_id = "${module.vpc.vpc_id}"
  az_id = "${var.region}b"
  az_cidr = "${lookup(var.cidr_blocks, "az1")}"

  default_security_group_id = "${module.vpc.default_security_group_id}"
}

module "az2" {
  source ="./aws/az"
  region = "${var.region}"
  vpc_id = "${module.vpc.vpc_id}"
  az_id = "${var.region}c"
  az_cidr = "${lookup(var.cidr_blocks, "az2")}"

  default_security_group_id = "${module.vpc.default_security_group_id}"
}
