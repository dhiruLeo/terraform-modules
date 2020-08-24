resource "aws_subnet" "public-subnet" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "ap-southeast-1a"

  tags {
    Name = "PublicSubnet"
  }
}