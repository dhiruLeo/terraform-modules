provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias  = "ses"
  region = "${var.region}"
}

# The role policy
data "aws_iam_policy_document" "lambda_sync_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda function
resource "aws_lambda_function" "lambda_fnc" {

  for_each = var.lambda_names.lambdas
  #filename      = data.archive_file.lambda-alert[each.key].output_path
  description   = contains(keys(each.value), "description") ? each.value.description : ""
  s3_bucket     = var.lambda-source-code-s3
  s3_key        = each.value.lambda-code-s3-key #"${aws_s3_bucket_object.source-code[each.key].key}"
  function_name = each.key
  role          = "${aws_iam_role.s3-lambda-role.arn}"
  handler       = each.value.handler

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  #source_code_hash = "${data.archive_file.lambda-alert[each.key].output_base64sha256}"

  runtime = each.value.runtime

  environment {
    variables = each.value.env

  }
  #depends_on    = ["aws_iam_role_policy_attachment.cloud-watch"]

}




#s3.tf
#S3 Bucket To put attachments

resource "aws_s3_bucket" "s3-trigger-bucket" {
  for_each = var.lambda_names.lambdas
  bucket   = each.value.triggering-s3
  tags     = { description = each.value.triggering-s3 }
  #acl    = "private"
  force_destroy = true

  # When objects are overwritten don't preserve the earlier versions just in case
  # versioning {
  #   enabled = true
  # }
  # # Never expire/delete anything from these buckets
  # lifecycle_rule {
  #   prefix = ""
  #   enabled = false

  #   # Move old reports to cheaper storage after they are not needed
  #   transition {
  #     # 5 years
  #     days = 1825
  #     storage_class = "GLACIER"
  #   }
  #   noncurrent_version_transition {
  #     # 5 years
  #     days = 1825
  #     storage_class = "GLACIER"
  #   }
  # }
}

# Policy for Cloudwatch

data "aws_iam_policy_document" "move_object" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      for lambda in keys(var.lambda_names.lambdas) :
      "${aws_s3_bucket.s3-trigger-bucket[lambda].arn}/*"
    ]
  }
}

# data "aws_iam_policy_document" "mailbox" {
#  statement {
#    effect = "Allow"
#    principals {
#      type = "Service"
#      identifiers = ["ses.amazonaws.com"]
#    }
#    actions = [
#      "s3:PutObject"
#    ]
#    resources = [
#        for lambda in keys(var.lambda_names.lambdas):
#         "${aws_s3_bucket.s3-trigger-bucket[lambda].arn}/*"
#        ]
#  }
# }

#Enable Put from SES to S3 bucket
resource "aws_s3_bucket_policy" "mailbox-policy" {
  for_each = var.lambda_names.lambdas
  bucket   = "${aws_s3_bucket.s3-trigger-bucket[each.key].id}"
  policy = jsonencode(
    {

      "Statement" : [
        {
          "Action" : "s3:PutObject"
          "Effect" : "Allow"
          "Principal" : {
            "Service" : "ses.amazonaws.com"
          }
          "Resource" : [
            "${aws_s3_bucket.s3-trigger-bucket[each.key].arn}/*"
            #"arn:aws:s3:::${each.value.triggering-s3}/*",

          ]

        }
      ]

  })

}

resource "aws_lambda_permission" "mailbox-policy" {
  statement_id  = "AllowExecutionFromSES"
  action        = "lambda:InvokeFunction"
  for_each      = var.lambda_names.lambdas
  function_name = "${aws_lambda_function.lambda_fnc[each.key].function_name}"
  principal     = "ses.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3-trigger-bucket[each.key].arn}"
}


resource "aws_ses_receipt_rule" "mailbox" {
  provider      = "aws.ses"
  rule_set_name = "${var.ses-rule-set-name}"
  for_each      = var.lambda_names.lambdas
  recipients    = ["${each.value.recipient-email}"]
  enabled       = true
  scan_enabled  = true
  name          = each.value.triggering-s3
  # lambda_action {
  #   function_arn = "${aws_lambda_function.lambda_fnc[each.key].arn}"
  #   invocation_type = "Event"
  #   position = "3"
  # }
  s3_action {
    bucket_name       = "${aws_s3_bucket.s3-trigger-bucket[each.key].id}"
    object_key_prefix = "mailbox/${each.value.recipient-email}"
    position          = 2 #this needs to be increment everytime we create resorce for new client 
  }

  stop_action {
    scope    = "RuleSet"
    position = "4"
  }
}


#trigger.tf

resource "aws_iam_role" "s3-lambda-role" {
  #name               = "s3-to-lambda"
  name = "${var.s3-lambda-role}"

  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"

    }
  ]
}
EOF
}
# define notification

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.lambda_names.lambdas
  bucket   = "${aws_s3_bucket.s3-trigger-bucket[each.key].id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda_fnc[each.key].arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "with_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  for_each      = var.lambda_names.lambdas
  function_name = "${aws_lambda_function.lambda_fnc[each.key].function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3-trigger-bucket[each.key].arn}"
}


# Attach role to Managed Policy
# resource "aws_iam_policy_attachment" "cloud-watch" {
#  name = "CloudWatchExecPolicy"
#  roles = ["${aws_iam_role.s3-lambda-role.id}"]
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }



# # Create a new rule set
# resource "aws_ses_receipt_rule_set" "mailbox" {
#  provider = "aws.ses"
#  rule_set_name = "${var.ses-rule-set-name}"
# }

# Activate rule set
# resource "aws_ses_active_receipt_rule_set" "mailbox" {
#   provider = "aws.ses"
#   rule_set_name = "${var.ses-rule-set-name}"
# }


# # Attach role to Managed Policy
# resource "aws_iam_policy_attachment" "cloud-watch" {
#   name = "CloudWatchExecPolicy"
# #  roles = [] # ["${aws_iam_role.s3-lambda-role.id}"]
#   roles = ["${aws_iam_role.s3-lambda-role.id}"]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }



# The discrete role policy, which connects the IAM role and the policy
#resource "aws_iam_role_policy" "lambda_sync_permissions" {
#  name   = "lambda_sync_permissions"
#  role   = "${aws_iam_role.sync.id}"
#  policy = "${data.aws_iam_policy_document.move_object.json}"
#}

# The IAM role actually used by the lambda functions
#resource "aws_iam_role" "sync" {
#  name               = "sync"
#  assume_role_policy = "${data.aws_iam_policy_document.lambda_sync_execution_policy.json}"
#}

# zip local file/folder

#data "archive_file" "lambda-source" {
#  type  = "zip"
#  for_each = var.lambda_names.lambdas
#  source_dir = each.value.local_source
#  output_path = "${basename(each.value.local_source)}.zip"
# }


##copy source to bucket

#resource "aws_s3_bucket_object" "source-code" {
#  bucket = "${aws_s3_bucket.s3-lambda-source.bucket}"
#  for_each = var.lambda_names.lambdas
#  key    = "${data.archive_file.lambda-source[each.key].output_path}"
#  source = "${data.archive_file.lambda-source[each.key].output_path}"
#
#  # The filemd5() function is available in Terraform 0.11.12 and later
#  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
#  # etag = "${md5(file("${data.archive_file.lambda-source.output_path}"))}"
#  etag = "${filemd5("${data.archive_file.lambda-source[each.key].output_path}")}"
#}



#output "ip" {
# value = "${aws_s3_bucket_policy.mailbox-policy}" #"${aws_lambda_function.lambda_fnc}"
#}
