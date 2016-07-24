variable "vpc_id" {}
variable "az_id" { }
variable "az_cidr" { default = "10.42.0.0/18" }

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
