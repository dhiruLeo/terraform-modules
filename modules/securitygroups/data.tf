data "aws_vpc" "vpc" {
  tags = "${merge(map("Name", "${format("%s-%s-vpc",var.name,var.environment)}"),"${var.common_tags}")}"
}

output "id" {
  value = "${data.aws_vpc.vpc.id}"
}

output "cidr_block" {
  value = "${data.aws_vpc.vpc.cidr_block}"
}
