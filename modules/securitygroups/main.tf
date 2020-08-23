provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_security_group" "eks-master-sg" {
  name        = "${var.name}-${var.environment}-eks-master-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${format("%s-%s-sg-master", var.name,var.environment)}"),map("sg-type","master"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${var.common_tags}")}"
}

resource "aws_security_group" "eks-node-sg" {
  name        = "${var.name}-${var.environment}-eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  ingress {
    from_port   = 0
    protocol    = "udp"
    to_port     = 65535
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${format("%s-%s-sg-node", var.name,var.environment)}"),map("sg-type","node"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${var.common_tags}")}"
}


resource "aws_security_group" "db-node-sg" {
  name        = "${var.name}-${var.environment}-db-sg"
  description = "Security group for all db in the cluster"
  vpc_id      = "${data.aws_vpc.vpc.id}"


  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", "${format("%s-%s-sg-db", var.name,var.environment)}"),map("sg-type","db"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${var.common_tags}")}"
}
