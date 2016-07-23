provider "aws" {
  region = "${var.region}"
}

variable "region" {default = "us-west-2"}
variable "name" {default = "docker-infra-quickstart"}

module "vpc" {
  source ="./aws/vpc"
  name = "${var.name}"
  region = "${var.region}"
}
