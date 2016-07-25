# The instance module defines a parameterized method for creating AWS instances

variable "count" {default = "1"}
variable "count_format" {default = "%02d"}
#variable "iam_profile" {default = "" }
variable "ec2_type" {default = "m3.medium"}
variable "ebs_volume_size" {default = "15"} # size is in gigabytes
variable "ebs_volume_type" {default = "gp2"}
variable "data_ebs_volume_size" {default = "20"} # size is in gigabytes
variable "data_ebs_volume_type" {default = "gp2"}
variable "role" {}
variable "short_name" {default = "infra"}
variable "availability_zone" {}
variable "ssh_key_pair" {}
variable "source_ami" {}
variable "security_group_ids" {}
variable "vpc_subnet_ids" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "ebs" {
  availability_zone = "${var.availability_zone}"
  count = "${var.count}"
  size = "${var.data_ebs_volume_size}"
  type = "${var.data_ebs_volume_type}"

  tags {
    Name = "${var.short_name}-${var.role}-lvm-${format(var.count_format, count.index+1)}"
    CreatedBy = "terraform"
  }
}


resource "aws_instance" "instance" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.ec2_type}"
  count = "${var.count}"
  vpc_security_group_ids = [ "${split(",", var.security_group_ids)}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${element(split(",", var.vpc_subnet_ids), count.index)}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }


  tags {
    Name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "${var.role}"
    CreatedBy = "terraform"
  }
}


resource "aws_volume_attachment" "instance-lvm-attachment" {
  count = "${var.count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.ebs.*.id, count.index)}"
  force_detach = true
}



output "hostname_list" {
  value = "${join(\",\", aws_instance.instance.*.tags.Name)}"
}

output "ec2_ids" {
  value = "${join(\",\", aws_instance.instance.*.id)}"
}

output "ec2_ips" {
  value = "${join(\",\", aws_instance.instance.*.public_ip)}"
}
