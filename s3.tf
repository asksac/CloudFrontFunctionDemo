resource "aws_s3_bucket" "cf_s3_origin" {
  bucket                    = "${local.account_id}-${var.app_shortcode}-origin"
  acl                       = "private"

  tags                      = local.common_tags
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions                 = [ "s3:GetObject" ]
    resources               = [ "${aws_s3_bucket.cf_s3_origin.arn}/*" ]

    principals {
      type                  = "AWS"
      identifiers           = [ aws_cloudfront_origin_access_identity.cf_s3_origin_access_id.iam_arn ]
    }
  }

  statement {
    actions                 = [ "s3:ListBucket" ]
    resources               = [ aws_s3_bucket.cf_s3_origin.arn ]

    principals {
      type                  = "AWS"
      identifiers           = [ aws_cloudfront_origin_access_identity.cf_s3_origin_access_id.iam_arn ]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_s3_origin_policy" {
  bucket                    = aws_s3_bucket.cf_s3_origin.id
  policy                    = data.aws_iam_policy_document.s3_bucket_policy.json 
}

resource "aws_s3_bucket_object" "cf_s3_origin_index_html" {
  bucket                    = aws_s3_bucket.cf_s3_origin.id
  key                       = "index.html"
  source                    = "${path.module}/src/webapp/index.html"
  content_type              = "text/html"
  etag                      = filemd5("${path.module}/src/webapp/index.html")
}

