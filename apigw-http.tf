# # Create HTTP API Gateway (v2) with Lambda Integration

# resource "aws_apigatewayv2_api" "lambda_apigw" {
#   name                      = "${var.app_shortcode}-apigw"
#   protocol_type             = "HTTP"
#   description               = "HTTP API Gateway for ${var.app_name}"

#   tags                      = local.common_tags
# }

# # Creates Integration and Route for Hello Lambda Function

# resource "aws_apigatewayv2_integration" "lambda_integration" {
#   api_id                    = aws_apigatewayv2_api.lambda_apigw.id
#   integration_type          = "AWS_PROXY"
#   description               = "Lambda Function Integration"

#   connection_type           = "INTERNET"

#   integration_method        = "POST"
#   integration_uri           = aws_lambda_function.lambda_function.invoke_arn
#   payload_format_version    = "1.0"
# }

# resource "aws_apigatewayv2_route" "lambda_route" {
#   api_id                    = aws_apigatewayv2_api.lambda_apigw.id
#   route_key                 = "GET /hello"
#   target                    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
#   depends_on                = [ aws_apigatewayv2_integration.lambda_integration ]
# }

# resource "aws_apigatewayv2_stage" "lambda_apigw_default_stage" {
#   api_id                    = aws_apigatewayv2_api.lambda_apigw.id
#   name                      = var.apigw_stage_name
#   auto_deploy               = true

#   access_log_settings {
#     destination_arn         = aws_cloudwatch_log_group.apigw_log_group.arn
#     format                  = jsonencode(
#       {
#         httpMethod     = "$context.httpMethod"
#         ip             = "$context.identity.sourceIp"
#         protocol       = "$context.protocol"
#         requestId      = "$context.requestId"
#         requestTime    = "$context.requestTime"
#         responseLength = "$context.responseLength"
#         routeKey       = "$context.routeKey"
#         status         = "$context.status"
#       }
#     )
#     # xrayTraceId    = "$context.xrayTraceId"
#   }

#   depends_on                = [ aws_apigatewayv2_route.lambda_route ]

#   lifecycle {
#     ignore_changes          = [ deployment_id, default_route_settings, ] # route_settings
#   }

#   route_settings {
#     route_key               = aws_apigatewayv2_route.lambda_route.route_key
#     data_trace_enabled      = true
#     detailed_metrics_enabled  = true
#     logging_level           = "INFO"
#     throttling_burst_limit  = 100
#     throttling_rate_limit   = 100 
#   }
# }

