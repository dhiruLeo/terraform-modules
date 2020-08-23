data "aws_api_gateway_rest_api" "api"{
    name = "${var.name}"
}

data "aws_api_gateway_resource" "resource" {
  rest_api_id = "${data.aws_api_gateway_rest_api.api.id}"
  path        = "${var.parent_path}"
}


output "id" {
  value = "${data.aws_api_gateway_rest_api.api.id}"
}

output "name" {
  value = "${data.aws_api_gateway_rest_api.api.id}"
}

output "resource_id" {
  value = "${data.aws_api_gateway_resource.resource.id}"
}

