resource "aws_instance" "linux_instances" {
  count         = "${var.count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  subnet_id     = "${var.subnet_ids[0]}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  # iam_instance_profile = "${var.instance_profile}"

  vpc_security_group_ids = [
    "${aws_security_group.linux_instances.id}",
    "${var.default_security_group_id}",
  ]

  user_data = "${element(data.template_file.user_data.*.rendered, count.index)}"

  connection {
    user        = "ubuntu"
    private_key = "${file("${var.ssh_key_name}.pem")}"
  }

  provisioner "file" {
    source      = "${var.ssh_key_name}.pem"
    destination = "/tmp/${var.ssh_key_name}.pem"
  }

  tags {
    Name  = "${var.stack_name}-${lower(element(var.animal_names,count.index))}"
    Owner = "${lower(element(split("/",data.aws_caller_identity.current_user.arn),1))}"
  }
}

resource "aws_security_group" "linux_instances" {
  name        = "linux_instances_all"
  description = "Allow all traffic from anywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
