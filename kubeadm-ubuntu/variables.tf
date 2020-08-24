variable "k8stoken" {
  default = "929da8.37d7badafa6fc5ce"
}

variable "shared_credentials_file" {
  default = "/Users/dhirendra/.aws/credentials"
}

variable "profile" {
  description = "AWS profile used to create resource"
  default     = "default"
}

variable "region" {
  default = "ca-central-1"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "vpc_id" {
  default = ""
}

variable "subnet_id" {
  default = ""
}
variable "aws_internet_gateway_id" {
  default = ""
}

variable "key_name" {
  default = "k8s-test"
}
variable "environment" {
  default = "dev"
}

variable "created_by" {
  default = "DevOps"
}

variable "name" {
  default = "klearnow"
}

variable "public_subnets" {
  type = "map"
  default = {
    "10.0.101.0/24" = "elb"
    "10.0.102.0/24" = "elb"
  }
}
variable "private_subnets" {
  type = "map"
  default = {
    "10.0.103.0/24" = "node"
    "10.0.104.0/24" = "node"

    "10.0.105.0/24" = "db"
    "10.0.106.0/24" = "db"

  }
}
variable "availability_zones" {
  type    = "list"
  default = ["ca-central-1a", "ca-central-1b"]
}

variable "master-userdata" {
  default = "master.sh"
}

variable "worker-userdata" {
  default = "worker.sh"
}


variable "ami" {
  default = "ami-0d0eaed20348a3389"
}

variable "instance_type" {
  default = "t2.medium"
}


variable "master_name" {
  default = "master"
}

variable "node_name" {
  default = "worker"
}
