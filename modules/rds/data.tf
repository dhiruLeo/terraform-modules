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

data "aws_subnet_ids" "db_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    environment = "${var.environment}"
    subnet-type = "db"
  }
}



data "aws_security_groups" "db-node" {
  tags = {
    environment = "${var.environment}"
    sg-type     = "db"
  }
}