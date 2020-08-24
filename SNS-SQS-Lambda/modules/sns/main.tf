resource "aws_sns_topic" "sns_topic" {
  name            = "${var.name}"
  display_name    = "${var.name}"
  delivery_policy = "${var.delivery_policy }"
}
