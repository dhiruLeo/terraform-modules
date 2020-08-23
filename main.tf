provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
  version                 = ">=2.0.0"
}

locals {
  common_tags = {
    environment = "${var.environment}"
    created_by  = "${var.created_by}"
  }
}

module "vpc" {
  source     = "./modules/vpc"
  shared_credentials_file = "${var.shared_credentials_file}"
  cidr_block = "${var.cidr_block}"
  tags       = "${merge(map("Name", "${format("%s-%s-vpc",var.name,var.environment)}"),map("kubernetes.io/cluster/${var.name}-${var.environment}", "owned"),"${local.common_tags}")}"
}

module "public_subnet" {
  source             = "./modules/public-subents"
  shared_credentials_file = "${var.shared_credentials_file}"
  vpc_id             = "${module.vpc.id}"
  common_tags        = "${local.common_tags}"
  name               = "${var.name}"
  environment        = "${var.environment}"
  public_subnets     = "${var.public_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "private-subent" {
  source             = "./modules/private-subents"
  shared_credentials_file = "${var.shared_credentials_file}"
  vpc_id             = "${module.vpc.id}"
  common_tags        = "${local.common_tags}"
  name               = "${var.name}"
  environment        = "${var.environment}"
  private_subnets    = "${var.private_subnets}"
  availability_zones = "${var.availability_zones}"
}

module "securitygroups" {
  source      = "./modules/securitygroups"
  shared_credentials_file = "${var.shared_credentials_file}"
  vpc_id      = "${module.vpc.id}"
  common_tags = "${local.common_tags}"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "eks" {
  source      = "./modules/eks"
  common_tags = "${local.common_tags}"
  shared_credentials_file = "${var.shared_credentials_file}"
  name        = "${var.name}"
  environment = "${var.environment}"
}


module "rds" {
  source      = "./modules/rds"
  shared_credentials_file = "${var.shared_credentials_file}"
  common_tags = "${local.common_tags}"
  name        = "${var.name}"
  environment = "${var.environment}"
  availability_zones = "${var.availability_zones}"
  db_subnet_group = "dev-db-subnet-group"
  cluster_name = "dev-rds-aurora-cluster"
  database_name= "test"
}


output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}

output "config-map-aws-auth" {
  value = "${module.eks.config-map-aws-auth}"
}
