variable "name" {}

variable "env" {}

variable "delay_seconds" {
  default = "120"
}
variable "max_message_size" {
  default = ""
}
variable "message_retention_seconds" {
  default = ""
}
variable "receive_wait_time_seconds" {
  default = ""
}
variable "redrive_policy" { }

variable "tags" {
  type = "map"
}
