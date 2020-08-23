resource "aws_api_gateway_integration_response" "ResourceMethodIntegration400" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.ResourceMethod400.status_code}"
  response_templates = {
    "application/json" = "${var.integration_error_template}"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
}