output "arn" {
   value = "${aws_sns_topic.sns_topic.arn}"
}
output "id" {
   value = "${aws_sns_topic.sns_topic.id}"
}