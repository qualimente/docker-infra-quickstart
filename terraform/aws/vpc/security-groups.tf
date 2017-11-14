resource "aws_security_group" "bastion" {
  name = "${var.name}-bastion"
  description = "Inbound traffic for ${var.name} bastion nodes"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    CreatedBy = "terraform"
  }

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}