variable "shared_credentials_file" {
  default = "/Users/rajeev/.aws/"
}

variable "profile" {
  default = "default"
}

variable "region" {
  default = "us-west-2"
}

variable "name" {
  default = "TestAPI"
}

variable "parent_path" {
  description = "ID of parent path"
  default     = "/"
}

variable "path_part" {
  description = "The last path segment of this API resource"
  default     = "hello"
}
