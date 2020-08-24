terraform {
  backend "s3" {
    bucket = "oc-terraform-states-test"
    key    = "sqs/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  tags = {
      env = "${var.env}"
  }
}


provider "aws" {
   access_key = "${var.access_key}"
   secret_key = "${var.secret_key}"
   region = "${var.region}"
}


module "sqs" {
  source = "modules/sqs"
  name = "${var.env}-${var.name}"
  tags = "${local.tags}"

}

module "sns" {
  source = "modules/sns"
  name = "${var.env}-${var.name}" 
  delivery_policy = "${file("${path.module}/data/sns/delivery_policy")}"
}

data "template_file" "sns_policy_file" {
  template = "${file("data/sns/sns_policy")}"
  vars {
    arn = "${module.sns.arn}"
    account_id = "${var.account_id}"
  }
}

module "sns_policy" {
  source = "modules/sns-policy"
  arn = "${module.sns.arn}"
  policy = "${data.template_file.sns_policy_file.rendered}"
}



data "template_file" "sqs_policy_file" {
  template = "${file("data/sqs/sqs_queue_policy")}"
  vars {
    arn = "${module.sns.arn}"
  }
}

module "sqs_policy" {
  source = "modules/sqs-policy"
  id = "${module.sqs.id}"
  policy = "${data.template_file.sqs_policy_file.rendered}"
}

module "subscribe_sns_topic" {
  source = "modules/sns_topic_subscription"
  topic_arn = "${module.sns.arn}"
  endpoint = "${module.sqs.arn}"
}
