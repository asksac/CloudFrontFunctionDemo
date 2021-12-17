## Outputs

output "s3_origin_bucket_dns" {
  value                     = aws_s3_bucket.cf_s3_origin.bucket_regional_domain_name
}

output "cf_domain_name" {
  value                     = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "api_invoke_url" {
  value                     = aws_api_gateway_stage.api_stage.invoke_url
}

/*
output "api_endpoint" {
  value                     = aws_apigatewayv2_api.lambda_apigw.api_endpoint
}

output "api_exec_arn" {
  value                     = aws_apigatewayv2_api.lambda_apigw.execution_arn
}

output "api_invoke_url" {
  value                     = aws_apigatewayv2_stage.lambda_apigw_default_stage.invoke_url
}
*/
