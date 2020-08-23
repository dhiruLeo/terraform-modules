# resource "aws_api_gateway_integration" "request_method_integration" {
#  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#  resource_id = "${aws_api_gateway_resource.proxy.id}"
#  http_method = "${aws_api_gateway_method.request_method.http_method}"
#  type        = "AWS_PROXY"
#  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"

#   AWS lambdas can only be invoked with the POST method
#   integration_http_method = "POST"
# }

resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "${var.method}"
  authorization = "NONE"
}