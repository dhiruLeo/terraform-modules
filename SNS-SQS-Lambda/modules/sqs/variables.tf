variable "name" {}

variable "delay_seconds" {
  default = "1"
}

variable "max_message_size" {
  default = "262144"
}

variable "message_retention_seconds" {
  default = "345600"
}

variable "receive_wait_time_seconds" {
  default = "0"
}

variable "visibility_timeout_seconds" {
  default = "130"
}

variable "redrive_policy" {
  default = ""
}

variable "tags" {
  type = "map"
}
