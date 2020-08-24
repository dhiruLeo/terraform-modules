
variable "region" {
 default = "eu-west-1"
}

variable "lambda-source-code-s3" {
  description = "s3 bucket which contains the source code for all lambdas"
  default = "seslambdasource" #"source-codes"
}
variable "s3-lambda-role" {
  description = "IAM Role For Lambda Invocation"
  default = "s3-to-lambda2" #"source-codes"
}

variable "ses-rule-set-name" {
 description = "name of a pre-existent or any new rule set name"
 default = "SES-rule-set"
}


variable "lambda_names" {
 description = "Lambda function names with name as key and values as a map of environments variables "
  default = {
   lambdas = {
      clientname2 =  {
            #optional description
            description = "Ingester lambda"
            # runtime environment
            runtime = "java8"
            #s3 bucket key of lambda code file name (zip or jar)
            lambda-code-s3-key = "DwellMailIngester.zip"
            #s3 lambda triggering bucket name
            triggering-s3 = "demoseslambda2"
            # name of lambda handler function
            handler = "com.kx.lambda.dwell.DwellMailIngesterHandler::handleRequest"
            env = {
                   AWSHOST = "api.klearexpress.com/dev"
                   AWS_ATTACHMENTS_S3_BUCKET = "kxr-attachments-public1"
                   AWS_IMAGES_S3_BUCKET = ""
                   CUSTOMER_EMAIL = "yahoo.com"

                  }
            #SES mailbox id
            recipient-email = "dhirendra.yadav@yahoo.com"
            }
   # Node = {
   #         # runtime environment
   #         runtime = "nodejs8.10"
   #         lambda-code-s3-key = "kx.zip"
   #         #s3 lambda triggering bucket name
   #         triggering-s3 = "gulp-it-node"
   #         # name of file containing handler function
   #         handler = "kx"
   #         env = {
   #                AWSHOST = "api.klearexpress.com/dev"
   #                AWS_ATTACHMENTS_S3_BUCKET = "kxr-attachments-public"
   #                AWS_IMAGES_S3_BUCKET = ""
   #                CUSTOMER_EMAIL = "yahoo.com"

   #               }
   #         #SES mailbox id
   #         recipient-email = "mm@yahoo.com"
   #         }

         }
      }

}























