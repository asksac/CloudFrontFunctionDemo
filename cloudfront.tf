# CloudFront setup 

locals {
  s3_origin_id            = "${var.app_shortcode}_s3_origin"
  apigw_origin_id         = "${var.app_shortcode}_api_origin"
}

resource "aws_cloudfront_origin_access_identity" "cf_s3_origin_access_id" {
  comment                 = "S3 origin access identity for ${aws_s3_bucket.cf_s3_origin.id} bucket"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled                 = true
  is_ipv6_enabled         = true
  comment                 = "${var.app_name} CloudFront Distribution"
  default_root_object     = "index.html"

  price_class             = "PriceClass_100" # US, Canada and Europe only

  restrictions {
    geo_restriction {
      restriction_type    = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  wait_for_deployment     = false 

  origin {
    domain_name           = aws_s3_bucket.cf_s3_origin.bucket_regional_domain_name
    origin_id             = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_s3_origin_access_id.cloudfront_access_identity_path
    }
  }

  origin {
    #domain_name           = replace(aws_apigatewayv2_api.lambda_apigw.api_endpoint, "/^https?://([^/]*).*/", "$1")
    domain_name           = "${aws_api_gateway_rest_api.lambda_apigw.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_id             = local.apigw_origin_id
    #origin_path           = "/${var.apigw_stage_name}" # do not put the stage name 

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods       = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods        = ["GET", "HEAD"]
    target_origin_id      = local.s3_origin_id

    forwarded_values {
      query_string        = false
      cookies {
        forward           = "none"
      }
    }

    viewer_protocol_policy= "redirect-to-https"
    min_ttl               = 0
    default_ttl           = 3600
    max_ttl               = 86400
    compress              = true
  }

  ordered_cache_behavior {
    path_pattern          = "/api/*"
    allowed_methods       = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods        = ["GET", "HEAD"]
    target_origin_id      = local.apigw_origin_id

    default_ttl           = 0
    min_ttl               = 0
    max_ttl               = 0

    forwarded_values {
      query_string        = true
      headers             = [
        "Authorization", 
        "User-Agent", 
        "X-Amzn-Trace-Id", 
      ]
      cookies {
        forward           = "all"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.trace_id_header.arn
    }

    viewer_protocol_policy = "https-only"
  }
  
  tags                    = local.common_tags
}

resource "aws_cloudfront_function" "trace_id_header" {
  name                    = "AddTraceIdHeader"
  runtime                 = "cloudfront-js-1.0"
  comment                 = "CF function to add x-amzn-trace-id header in request path"
  publish                 = true
  code                    = file("${path.module}/src/cf-functions/traceid.js")
}