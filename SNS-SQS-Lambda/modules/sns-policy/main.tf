resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = "${var.arn}"
  policy = "${var.policy}"
}
