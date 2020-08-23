variable "method" {
  description = "The HTTP method"
  default     = "GET"
}

variable "response_model" {
  default = "Empty"
}

variable "rest_api_id" {
  description="ID of associated REST API"
}


variable "resource_id" {
    description = " Resource ID (required)"

}

variable "profile" {
 description = "profile name to get valid credentials of account"
 default = "default"
}