provider "aws" {
  region = "${var.region}"
}

variable "name" {default = "docker-infra-quickstart"}
variable "environment" {
  description = "Environment tag, recommendation: <account name>_<region>, e.g. prod_us-west-2"
  default     = "qm_us-west-2"
}

variable "region" {default = "us-west-2"}

# Define CIDR blocks for the VPC and Availability Zones within the VPC
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
# A key network design goal is to enable the AZ to a significant number of c-blocks to support network segmentation
# Providing a /18 network to the AZ enables further division of up to 64 c-block-sized subnets
variable "vpc_cidr" {default = "10.42.0.0/16"}
variable "az_cidr_blocks" {
  type = "map"
  default = {
    "us-west-2a" = "10.42.0.0/18"
    "us-west-2b" = "10.42.64.0/18"
    "us-west-2c" = "10.42.128.0/18"
    #az3 = "10.42.192.0/18" # could add a fourth az, if region permits
  }
}

module "vpc" {
  source = "./aws/vpc"
  name = "${var.name}"
  environment = "${var.environment}"
  region = "${var.region}"
  cidr = "10.42.0.0/16"
  az_cidr_blocks = "${var.az_cidr_blocks}"
}

module "keypairs" {
  source ="./aws/keypairs"
}
