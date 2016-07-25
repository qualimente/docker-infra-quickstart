variable "region" {}
variable "vpc_id" {}
variable "az_id" {}
variable "az_cidr" { default = "10.42.0.0/18" }
variable "default_security_group_id" {}

# TODO pull-up
variable "mgmt-key_name" { default = "key-infra-mgmt" }
variable "instance_type-bastion" { default = "t2.small" }

variable "amis" {
  #CentOS 7 HVM w/ Updates
  default = {
    us-east-1 = "ami-6d1c2007"
    us-west-1 = "ami-af4333cf"
    us-west-2 = "ami-d2c924b2"
  }
}

resource "aws_subnet" "dmz" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${cidrsubnet(var.az_cidr, 6, 0)}"
  availability_zone = "${var.az_id}"
  tags {
    Name = "${var.az_id}-dmz"
    CreatedBy = "terraform"
  }
}

resource "aws_subnet" "app" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${cidrsubnet(var.az_cidr, 6, 1)}"
  availability_zone = "${var.az_id}"
  tags {
    Name = "${var.az_id}-app"
    CreatedBy = "terraform"
  }
}

resource "aws_subnet" "mgmt" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${cidrsubnet(var.az_cidr, 6, 2)}"
  availability_zone = "${var.az_id}"
  tags {
    Name = "${var.az_id}-mgmt"
    CreatedBy = "terraform"
  }
}

module "bastion-nodes" {
  source = "../instance"
  count = 1
  role = "bastion"
  ec2_type = "${var.instance_type-bastion}"
  source_ami = "${lookup(var.amis, var.region)}"
  ssh_key_pair = "${var.mgmt-key_name}"
  availability_zone = "${var.az_id}"
  security_group_ids = "${var.default_security_group_id}"
  vpc_subnet_ids = "${aws_subnet.mgmt.id}"
}
