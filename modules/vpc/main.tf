provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${var.tags}"
}

##====================================# DHCP Options #=======================================
resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${var.dhcp_options_domain_name}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${var.tags}"

  # lifecycle {
  #   ignore_changes = ["tags.%"]
  # }
}

##====================================# DHCP Options Set Association #=======================
resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}
