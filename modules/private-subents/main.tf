provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_eip" "nateip" {
  vpc = true

  # count = "${length(var.availability_zones)}"

  tags = "${merge(map("Name", "${format("%s-%s-%s", var.name,var.environment,   element(split("-", var.availability_zones[0]),2))}"),"${var.common_tags}")}"
}

resource "aws_nat_gateway" "nat" {
  #allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  allocation_id = "${aws_eip.nateip.id}"

  #  subnet_id     = "${element(var.public_subnet_ids, count.index)}"
  subnet_id = "${data.aws_subnet_ids.public_subnet_ids.ids[0]}" #, count.index)}"

  #count         = "${length(var.availability_zones)}"

  tags = "${merge(map("Name", "${format("%s-%s-%s", var.name,var.environment,element(split("-",var.availability_zones[0]),2))}"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${var.common_tags}")}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  cidr_block        = "${element(keys(var.private_subnets), count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.private_subnets)}"

  tags = "${merge(map("Name", "${format("%s-%s-private-%s-%s", var.name,var.environment, lookup(var.private_subnets, element(keys(var.private_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)),2))}"),map("subnet-type","${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"),map("az","${element(var.availability_zones, count.index)}"),"${var.common_tags}")}"

  lifecycle {
    ignore_changes = ["tags.%"]
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  count  = "${length(var.availability_zones)}"

  tags = "${merge(map("Name", "${format("%s-%s-%s-rt-private-%s", var.name,var.environment, lookup(var.private_subnets, element(keys(var.private_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)),2))}"),map("subnet-type","${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"),map("az","${element(var.availability_zones, count.index)}"),"${var.common_tags}")}"
}

resource "aws_route" "private-route" {
  count                  = "${length(var.availability_zones)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
