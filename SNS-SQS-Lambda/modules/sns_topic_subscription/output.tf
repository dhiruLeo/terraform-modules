output "arm" {
  value = "${aws_sns_topic_subscription.sns_topic_subscription.arn}"
}

output "id" {
  value = "${aws_sns_topic_subscription.sns_topic_subscription.id}"
}
