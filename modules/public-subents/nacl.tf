/**
 * File to define multiple security groups based on type of application
 *
 */

resource "aws_network_acl" "elb" {
  vpc_id     = "${var.vpc_id == "" ? data.aws_vpc.vpc.id : var.vpc_id}"
  subnet_ids = ["${aws_subnet.public.*.id[0]}"]
  #subnet_ids      = "${element(aws_subnet.public.*.id, count.index)}"
  #subnet_id     = "${aws_subnet.public.*.id[0]}"



  // allows traffic from internet to our services behind elb
  // also includes traffic from private subnet to internet through it
  ingress {
    from_port  = 80
    to_port    = 80
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  // allows traffic from internet to our services behind elb
  // also includes traffic from private subnet to internet through it
  ingress {
    from_port  = 443
    to_port    = 443
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 22
    to_port    = 22
    rule_no    = 300
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 400
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 53
    to_port    = 53
    rule_no    = 500
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 600
    action     = "allow"
    protocol   = "udp"
    cidr_block = "0.0.0.0/0"
  }

  //allows traffic to install any packages
  egress {
    from_port  = 0
    to_port    = 65535
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 65535
    rule_no    = 200
    action     = "allow"
    protocol   = "udp"
    cidr_block = "0.0.0.0/0"
  }

  count      = "${length(matchkeys(keys(var.public_subnets), values(var.public_subnets),list("elb"))) >= 1 ? 1 : 0}"
  depends_on = ["aws_subnet.public"]
  tags       = "${merge(map("Name", "${format("%s-%s-acl-elb", var.name,var.environment)}"),map("role","${lookup(var.public_subnets, element(keys(var.public_subnets), count.index))}"),"${var.common_tags}")}"
}
