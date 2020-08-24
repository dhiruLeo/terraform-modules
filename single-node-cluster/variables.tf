

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

variable "ubuntu_ami" {
    type = "string"
    default = "ami-0dad20bd1b9c8c004"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}
