# ---- Inputs (dummy placeholders for portfolio) ----
variable "mode" {
  description = "Deployment mode (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# S3 bucket for static site hosting (private, served via CloudFront OAI)
resource "aws_s3_bucket" "web_bucket" {
  bucket        = "example-web-${var.mode}-bucket" # <-- dummy name; replace with a unique bucket when deploying
  force_destroy = true

  tags = {
    Name        = "example-web-${var.mode} Bucket"
    Environment = var.mode
  }
}

resource "aws_s3_bucket_ownership_controls" "web_bucket_acl_ownership" {
  bucket = aws_s3_bucket.web_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "web_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.web_bucket_acl_ownership]

  bucket = aws_s3_bucket.web_bucket.id
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Example Web ${var.mode} OAI"
}

locals {
  s3_origin_id = "web_bucket_origin"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_function" "rewrite_to_index" {
  name    = "example_web_rewrite_to_index_${var.mode}"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite folder URL to index.html file"
  publish = true
  code    = file("${path.module}/rewrite.js")
}

# CloudFront distribution for the S3 website
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = var.aliases # defined in the first sanitized file

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_to_index.arn
    }
  }

  tags = {
    Environment = var.mode
  }

  viewer_certificate {
    # Uses the sanitized ACM cert from us-east-1 (alias: aws.virginia) defined in the first file
    acm_certificate_arn = aws_acm_certificate.site_cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_caching_min_ttl = 5
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  depends_on = [
    aws_acm_certificate.site_cert,
    aws_acm_certificate_validation.site_cert,
    aws_cloudfront_function.rewrite_to_index
  ]
}
