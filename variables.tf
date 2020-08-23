variable "shared_credentials_file" {
  default = "/Users/dhiru/.aws/credentials"
}

variable "profile" {
  description = "AWS profile used to create resource"
  default     = "default"
}

variable "region" {
  description = "Region used to deploy resources "
  default     = "eu-west-1"
}

variable "environment" {
  default = "dev"
}

variable "created_by" {
  default = "DevOps"
}

variable "name" {
  default = "dhiru"
}

######################### VPC ################
variable "cidr_block" {
  default = "10.10.0.0/16"
}

variable "availability_zones" {
  type    = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

##################### Public Subnets ###########
variable "public_subnets" {
  type = "map"

  default = {
    "10.10.0.0/24" = "elb"
    "10.10.4.0/24" = "elb"
    "10.10.8.0/24" = "elb"
  }
}

variable "private_subnets" {
  type = "map"

  default = {
    "10.10.12.0/24" = "master"
    "10.10.16.0/24" = "master"
    "10.10.20.0/24" = "master"

    "10.10.24.0/24" = "node"
    "10.10.28.0/24" = "node"
    "10.10.32.0/24" = "node"

    "10.10.36.0/24" = "db"
    "10.10.40.0/24" = "db"
    "10.10.44.0/24" = "db"
  }
}
