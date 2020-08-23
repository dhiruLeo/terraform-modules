data "aws_vpc" "vpc" {
  tags = "${merge(map("Name", "${format("%s-%s-vpc",var.name,var.environment)}"),"${var.common_tags}")}"
}

output "id" {
  value = "${data.aws_vpc.vpc.id}"
}

output "cidr_block" {
  value = "${data.aws_vpc.vpc.cidr_block}"
}

#################### Get Public subnet ids ########################

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
  depends_on = ["aws_subnet.private"]
}

data "aws_subnet_ids" "node_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "node"
  }
  depends_on = ["aws_subnet.private"]
}

data "aws_subnet_ids" "db_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "db"
  }
  depends_on = ["aws_subnet.private"]
}

output "ids" {
  value = "${data.aws_subnet_ids.public_subnet_ids.ids}"
}

output "master_subnet_ids" {
  value = "${data.aws_subnet_ids.master_subnet_ids.ids}"
}

output "node_subnet_ids" {
  value = "${data.aws_subnet_ids.node_subnet_ids.ids}"
}

output "db_subnet_ids" {
  value = "${data.aws_subnet_ids.db_subnet_ids.ids}"
}
