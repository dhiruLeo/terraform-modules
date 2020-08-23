data "aws_vpc" "vpc" {
  tags = "${merge(map("Name", "${format("%s-%s-vpc",var.name,var.environment)}"),"${var.common_tags}")}"
}

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "elb"
  }
}

data "aws_subnet_ids" "master_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "master"
  }
}

data "aws_subnet_ids" "node_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "node"
  }
}

data "aws_subnet_ids" "db_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "db"
  }
}

data "aws_security_groups" "eks-master" {
  tags = {
    environment = "${var.environment}"
    sg-type     = "master"
  }
}

data "aws_security_groups" "eks-node" {
  tags = {
    environment = "${var.environment}"
    sg-type     = "node"
  }
}

data "template_file" "userdata-eks-node" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    cluster-endpoint              = "${aws_eks_cluster.aws-eks.endpoint}"
    cluster-certificate-authority = "${aws_eks_cluster.aws-eks.certificate_authority.0.data}"
    cluster-name                  = "${var.name}-${var.environment}"
  }
}
