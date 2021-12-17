#
# Upload and create Lambda function
#

data "archive_file" "lambda_archive" {
  source_file               = "${path.module}/src/lambdas/${var.lambda_function_name}/index.js"
  output_path               = "${path.module}/dist/${var.lambda_function_name}_lambda.zip"
  type                      = "zip"

  #depends_on = [ null_resource.lambda_build ]
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name 

  handler          = "index.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs12.x"
  #timeout          = 60

  filename         = data.archive_file.lambda_archive.output_path
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  #environment {
  #  variables = {
  #  }
  #}

  tags             = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30 
}

# Create Lambda execution IAM role, giving permissions to access other AWS services

resource "aws_iam_role" "lambda_exec_role" {
  name                = "${var.app_shortcode}_Lambda_Exec_Role"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
          "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaAssumeRolePolicy"
      }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.app_shortcode}_Lambda_Policy"
  path        = "/"
  description = "IAM policy with minimum permissions for Lambda function execution"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/*",
      "Effect": "Allow"
    }, 
    {
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

