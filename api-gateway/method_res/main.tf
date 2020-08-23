resource "aws_api_gateway_method_response" "api" {
  rest_api_id = "{var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.method}"
  status_code = "200"
}
