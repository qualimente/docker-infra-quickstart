variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}

resource "aws_key_pair" "mgmt" {
  key_name = "key-infra-mgmt"
  public_key = "${file(var.ssh_key)}"
}

output "mgmt-key_name" {
	value = "${aws_key_pair.mgmt.key_name}"
}