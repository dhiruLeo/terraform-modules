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

variable "name" {
    default = "srijan"

}

variable "environment" {
  default = "dev"
}

variable "k8s_master_version" {
  default = "1.11"
}

variable "node-ami-id" {
  description = "ami id for k8s worker node" // it is recommended to have our own AMI to avoid AWS AMI dependency
  default     = "ami-0a9006fb385703b54"      //ami-08dbb8e69f6565a0b
}

variable "node-instance-type" {
  default = "t2.medium"
}

variable "key" {
  default = "srijan"
}

variable "node_root_volume_size" {
  default = "30"
}

variable "volume_type" {
  default = "gp2"
}

variable "minimum-node" {
  default = "2"
}

variable "desired-node" {
  default = "2"
}

variable "maximum-node" {
  default = "2"
}
