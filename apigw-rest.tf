
# Create REST API Gateway with Lambda Integration

resource "aws_api_gateway_rest_api" "lambda_apigw" {
  name                      = "${var.app_shortcode}-apigw"
}

resource "aws_api_gateway_resource" "api_resource" {
  path_part                 = var.lambda_api_name
  parent_id                 = aws_api_gateway_rest_api.lambda_apigw.root_resource_id
  rest_api_id               = aws_api_gateway_rest_api.lambda_apigw.id
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_apigw.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_apigw.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_apigw.id

  triggers = {
    redeployment          = sha1(jsonencode([
      aws_api_gateway_resource.api_resource.id,
      aws_api_gateway_method.api_method.id,
      aws_api_gateway_integration.api_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id           = aws_api_gateway_deployment.api_deployment.id
  rest_api_id             = aws_api_gateway_rest_api.lambda_apigw.id
  stage_name              = var.apigw_stage_name

  xray_tracing_enabled    = true

  access_log_settings {
    destination_arn       = aws_cloudwatch_log_group.apigw_log_group.arn
    format                = jsonencode(
      {
        request_id        = "$context.requestId"
        api_id            = "$context.apiId"
        request_time      = "$context.requestTime"
        http_method       = "$context.httpMethod"
        resource_path     = "$context.resourcePath"
        source_ip         = "$context.identity.sourceIp"
        user_agent        = "$context.identity.userAgent"
        response_length   = "$context.responseLength"
        status            = "$context.status"
        xray_trace_id     = "$context.xrayTraceId"
        header_trace_id   = "$context.requestOverride.header.x-amzn-trace-id" # not working currently
      }
    )
  }

  tags                    = local.common_tags
}

resource "aws_lambda_permission" "lambda_invoke_permission" {
  statement_id            = "AllowLambdaExecution"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.lambda_function.function_name
  principal               = "apigateway.amazonaws.com"

  source_arn              = "${aws_api_gateway_rest_api.lambda_apigw.execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "apigw_log_group" {
  name                    = "/${var.app_shortcode}/apigw"
  retention_in_days       = 30 
}

# API Gateway region-level policy for CloudWatch access

resource "aws_api_gateway_account" "apigw_account_setting" {
  cloudwatch_role_arn     = aws_iam_role.apigw_cloudwatch_role.arn
}

resource "aws_iam_role" "apigw_cloudwatch_role" {
  name                    = "api_gateway_cloudwatch_global"

  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apigw_cloudwatch_policy" {
  name                    = "default"
  role                    = aws_iam_role.apigw_cloudwatch_role.id

  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}