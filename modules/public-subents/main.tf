provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  #count  = "${length(var.public_subnets) >= 1 ? 1 : 0}"
  #count             = "${length(var.public_subnets)}"
  tags   = "${merge(map("Name", "${format("%s-%s-igw",var.name,var.environment)}"),"${var.common_tags}")}"

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  cidr_block = "${element(keys(var.public_subnets), count.index)}"

  availability_zone = "${element(var.availability_zones, count.index)}"

  count = "${length(var.public_subnets)}"
  tags  = "${merge(map("Name", "${format("%s-%s-%s-public-%s", var.name,var.environment, lookup(var.public_subnets, element(keys(var.public_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)),2))}"),map("subnet-type","${lookup(var.public_subnets, element(keys(var.public_subnets), count.index))}"),map("az","${element(var.availability_zones, count.index)}"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${var.common_tags}")}"

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  count  = "${length(var.availability_zones)}"
  tags   = "${merge(map("Name", "${format("%s-%s-%s-public-rt-%s", var.name,var.environment, lookup(var.public_subnets, element(keys(var.public_subnets), count.index)), element(split("-", element(var.availability_zones, count.index)),2))}"),map("role","${lookup(var.public_subnets, element(keys(var.public_subnets), count.index))}"),map("az","${element(var.availability_zones, count.index)}"),"${var.common_tags}")}"

  lifecycle {
    ignore_changes = ["tags"]
  }
}
resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  count                  = "${length(var.availability_zones)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}
