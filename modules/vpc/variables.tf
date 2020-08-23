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

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = "ec2.internal"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "10.10.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "instance_tenancy" {
  default = "default"
}

variable "tags" {
  type = "map"
}
