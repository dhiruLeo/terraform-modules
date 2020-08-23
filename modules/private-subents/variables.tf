variable "shared_credentials_file" {
  default = ""
}
variable "profile" {
  description = "AWS profile used to create resource"
  default     = "default"
}

variable "region" {
  description = "Region used to deploy resources "
  default     = "eu-west-1"
}

variable "common_tags" {
  type = "map"
}

variable "name" {}

variable "vpc_id" {
  default = ""
}

variable "environment" {
  default = "dev"
}

variable "availability_zones" {
  type = "list"
}

variable "private_subnets" {
  type = "map"
}
