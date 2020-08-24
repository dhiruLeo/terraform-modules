
#1.VPC. output id & arn needs to be uncommented when creating VPC

output "id" {
  value = "${aws_vpc.main.id}"
}

output "arn" {
  value = "${aws_vpc.main.arn}"
}
output "node_subnet_ids" {
  value = "${data.aws_subnet_ids.node_subnet_ids.ids}"
}

##uncomment data vpc when creating public subnet

# output "zone_ids" {
#   value = "${data.aws_availability_zones.azs.zone_ids}"
# }


# output "cidr_block" {
#   value = "${data.aws_vpc.main.cidr_block}"
# }


# output "ids" {
#   value = "${data.aws_subnet_ids.public_subnet_ids.ids}"
# }

# output "master_subnet_ids" {
#   value = "${data.aws_subnet_ids.master_subnet_ids.ids}"
# }


# output "master_dns" {
#   value = "${aws_instance.k8s-master.public_dns}"
# }

