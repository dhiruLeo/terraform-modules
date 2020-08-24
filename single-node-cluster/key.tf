resource "aws_key_pair" "key" {
  key_name   = "example"
  public_key = "${file("example.pem")}"
}
