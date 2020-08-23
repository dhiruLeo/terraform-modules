/**
 * File to define multiple security groups based on type of application
 *
 */
resource "aws_network_acl" "db" {
  vpc_id     = "${data.aws_vpc.vpc.id}"
  subnet_ids = ["${data.aws_subnet_ids.db_subnet_ids.ids}"]

  ingress {
    from_port  = 0
    to_port    = 65535
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }

  // Allowing dns response from internal dns server
  ingress {
    from_port  = 0
    to_port    = 65535
    rule_no    = 200
    action     = "allow"
    protocol   = "udp"
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }

  // Alowing 80 and 443 to communicate with internet for any installation of packages or external repo access
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

  # count      = "${length(data.aws_subnet_ids.db_subnet_ids.ids) >= 1 ? 1 : 0}"
  depends_on = ["aws_subnet.private"]
  tags       = "${merge(map("Name", "${format("%s-%s-acl-db", var.name,var.environment)}"),map("role","${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"),"${var.common_tags}")}"
}

resource "aws_network_acl" "node" {
  vpc_id     = "${data.aws_vpc.vpc.id}"
  subnet_ids = ["${data.aws_subnet_ids.node_subnet_ids.ids}"]

  // allows ssh from office vpn
  ingress {
    from_port  = 22
    to_port    = 22
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 80
    to_port    = 80
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 443
    to_port    = 443
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

  // Allowing dns response from internal dns server
  ingress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 500
    action     = "allow"
    protocol   = "udp"
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }

  ingress {
    from_port  = 53
    to_port    = 53
    rule_no    = 700
    action     = "allow"
    protocol   = "udp"
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }
  // Alowing 80 and 443 to communicate with internet for any installation of packages or external repo access
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

  # count      = "${length(data.aws_subnet_ids.node_subnet_ids.ids) >= 1 ? 1 : 0}"
  depends_on = ["aws_subnet.private"]
  tags       = "${merge(map("Name", "${format("%s-%s-acl-node", var.name,var.environment)}"),map("role","${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"),"${var.common_tags}")}"
}

resource "aws_network_acl" "master" {
  vpc_id     = "${data.aws_vpc.vpc.id}"
  subnet_ids = ["${data.aws_subnet_ids.master_subnet_ids.ids}"]

  ingress {
    from_port  = 80
    to_port    = 80
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

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
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }
  ingress {
    from_port  = 53
    to_port    = 53
    rule_no    = 600
    action     = "allow"
    protocol   = "udp"
    cidr_block = "${data.aws_vpc.vpc.cidr_block}"
  }

  // Allowing dns response from internal dns server
  ingress {
    from_port  = 1024
    to_port    = 65535
    rule_no    = 400
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  //port required for DNS server running in k8s cluster
  ingress {
    from_port  = 0
    to_port    = 65535
    rule_no    = 500
    action     = "allow"
    protocol   = "udp"
    cidr_block = "0.0.0.0/0"
  }

  //nnect to Maquette staging service at internal-fraud-maquette-stg-1520498624.ap-south-1.elb.amazonaws.com
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

  # count      = "${length(data.aws_subnet_ids.master_subnet_ids.ids) >= 1 ? 1 : 0}"
  depends_on = ["aws_subnet.private"]
  tags       = "${merge(map("Name", "${format("%s-%s-acl-master", var.name,var.environment)}"),map("role","${lookup(var.private_subnets, element(keys(var.private_subnets), count.index))}"),"${var.common_tags}")}"
}
