data "aws_caller_identity" "current_user" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_string" "wetty" {
  length  = 16
  special = true
}

data "template_file" "user_data" {
  count    = "${var.count}"
  template = "${file("${path.module}/scripts/user_data_linux.sh")}"

  vars {
    hostname              = "${var.stack_name}-${element(var.animal_names, count.index)}"
    count                 = "${count.index}"
    ssh_user              = "${var.ssh_user}"
    ssh_pass              = "${var.ssh_password}"
    custom_install_script = "${element(var.custom_install_scripts,count.index)}"
    wetty_pw              = "${random_string.wetty.result}"
  }
}
