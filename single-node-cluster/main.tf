provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_instance" "master" {
  instance_type               = "t2.medium"
  ami                         = "${var.ubuntu_ami}"
  key_name                    = "${aws_key_pair.key.key_name}"
  security_groups             = ["${aws_security_group.mysg.id}"]
  subnet_id                   = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address = true

  tags {
    Name = "kube-master"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    agent       = true
    private_key = "${file("example.pem")}"
  }

  provisioner "file" {
    source      = "/Users/dhiru/K8S-cluster-master/master.sh"
    destination = "/tmp/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master.sh",
      "/tmp/master.sh",
    ]
  }

  provisioner "local-exec" {
    command = "scp -i /Users/dhiru/K8S-cluster-master/example.pem -o StrictHostKeyChecking=no ubuntu@${aws_instance.master.public_ip}:/tmp/join.sh /tmp/join.sh"
  }
}

resource "aws_instance" "node" {
  instance_type = "t2.medium"
  ami           = "${var.ubuntu_ami}"
  key_name      = "${aws_key_pair.key.key_name}"

  //count=2
  security_groups             = ["${aws_security_group.mysg.id}"]
  subnet_id                   = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address = true

  tags {
    Name = "kube-node"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    agent       = true
    private_key = "${file("example.pem")}"
  }

  provisioner "file" {
    source      = "/tmp/join.sh"
    destination = "/tmp/join.sh"
  }

  provisioner "file" {
    source      = "/Users/dhiru/Desktop/terraform/ec2-web-server/node.sh"
    destination = "/tmp/node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node.sh",
      "/tmp/node.sh",
    ]
  }

  depends_on = ["aws_instance.master"]
}
