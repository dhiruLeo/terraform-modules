/*
output "localaddress" {
  value = ["${aws_instance.web.*.private_ip}"]
}

output "publicaddress" {
  value = ["${aws_instance.web.*.public_ip}"]
}
*/

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
