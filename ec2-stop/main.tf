provider "aws" {
  region = "eu-central-1"
  profile = "vbecerrabit"
}

provider "archive" {
  version = ">=1.3"
}

# ----------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA EXPECTS A DEPLOYMENT PACKAGE
# A deployment package is a ZIP archive that contains your function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/main.py"
  output_path = "${path.module}/python/main.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY THE LAMBDA FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "lambda_stop" {

  function_name = "python-function-stop"
  description   = "Python Lambda function to start / stop EC2 instances"
  filename      = data.archive_file.lambda.output_path
  runtime       = "python3.8"
  role          = aws_iam_role.lambdaRole.arn
  handler       = "main.lambda_handler"
  timeout       = 300
  memory_size   = 128

}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM LAMBDA EXECUTION ROLE WHICH WILL BE ATTACHED TO THE FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambdaRole" {
      name = "lambdaRole"

      assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
          "Action": "sts:AssumeRole",
          "Principal": {
          "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
    }
    ]
}
EOF
}

# Created Policy for IAM Role (EC2, s3 and log access)
resource "aws_iam_policy" "policy" {
  name = "my-test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:*",
          "s3:Get*",
          "s3:List*"
          ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
  ]
}
EOF
}

# Attached IAM Role and the new created Policy
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambdaRole.name
  policy_arn = aws_iam_policy.policy.arn
}
