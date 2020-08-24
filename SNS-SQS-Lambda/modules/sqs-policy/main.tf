resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = "${var.id}"

  policy =  "${var.policy}"
  }