data "aws_vpc" "vpc" {
  tags = "${merge(map("Name", "${format("%s-%s-vpc",var.name,var.environment)}"),"${var.common_tags}")}"
}

output "id" {
  value = "${data.aws_vpc.vpc.id}"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

output "zone_ids" {
  value = "${data.aws_availability_zones.azs.zone_ids}"
}
