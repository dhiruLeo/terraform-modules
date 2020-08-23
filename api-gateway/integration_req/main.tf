resource "aws_api_gateway_integration" "demointegration" {
  rest_api_id          = "${var.rest_api_id}"
  resource_id          = "${var.resource_id}"
  http_method          = "${var.method}"
  type                 = "MOCK"
  cache_key_parameters = ["method.request.path.param"]
  cache_namespace      = "foobar"
  timeout_milliseconds = 29000

  request_parameters = {
    "integration.request.header.X-Authorization" = "'static'"
  }

  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }
}

# resource "aws_api_gateway_integration" "integration" {
#   rest_api_id             = "${var.rest_api_id}"
#   resource_id             = "${var.resource_id}"
#   http_method             = "${var.method}"
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
#   depends_on              = ["aws_api_gateway_method.cors_method", "aws_lambda_function.lambda"]
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = "${aws_api_gateway_rest_api.cors_api.id}"
#   stage_name  = "Dev"
#   depends_on  = ["aws_api_gateway_integration.integration"]
# }
