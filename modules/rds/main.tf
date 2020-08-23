provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

resource "aws_db_subnet_group" "subenet_group" {
  name       = "${var.db_subnet_group}"
  subnet_ids = ["${data.aws_subnet_ids.db_subnet_ids.ids}"]

  tags = "${merge(map("Name", "${format("%s-%s-db-subnet-group", var.name,var.environment)}"),"${var.common_tags}")}"
}




resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier           = "${var.cluster_name}"
  # engine                       = "${var.engine}"
  availability_zones           = "${var.availability_zones}"
  database_name                = "${var.database_name}"
  master_username              = "${var.master_username}"
  master_password              = "${var.master_password}"
  final_snapshot_identifier    = "${var.snapshot_name}"
  deletion_protection          = "true"
  preferred_backup_window      = "07:00-08:00" 
  db_subnet_group_name         = "${aws_db_subnet_group.subenet_group.id}"
  vpc_security_group_ids = ["${data.aws_security_groups.db-node.ids}"]

  # depends_on = "${aws_db_subnet_group.subenet_group}"
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count = "2"
  identifier           = "${var.cluster_name}-${count.index}"
  cluster_identifier   = "${aws_rds_cluster.aurora_cluster.id}"
  instance_class       = "${var.instance_class}"
  db_subnet_group_name = "${aws_db_subnet_group.subenet_group.id}"
}