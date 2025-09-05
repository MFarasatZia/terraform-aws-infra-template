#############################################
# S3 bucket for reports + CloudFront (concise)
#############################################

variable "name_prefix" { type = string, default = "demo" }

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# S3 bucket (private)
resource "aws_s3_bucket" "reports" {
  bucket        = "${var.name_prefix}-reports-${random_string.suffix.result}"
  force_destroy = true

  tags = { Name = "${var.name_prefix}-reports" }
}

resource "aws_s3_bucket_ownership_controls" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "reports" {
  depends_on = [aws_s3_bucket_ownership_controls.reports]
  bucket     = aws_s3_bucket.reports.id
  acl        = "private"
}

# CloudFront OAI (simple & compatible)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.name_prefix}-reports-oai"
}

# Allow CloudFront OAI to read the bucket
data "aws_iam_policy_document" "reports_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.reports.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "reports" {
  bucket = aws_s3_bucket.reports.id
  policy = data.aws_iam_policy_document.reports_read.json
}

# CloudFront distribution (default cert, redirects to HTTPS)
locals { s3_origin_id = "${var.name_prefix}-reports-origin" }

resource "aws_cloudfront_distribution" "reports" {
  origin {
    domain_name = aws_s3_bucket.reports.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"  # safer than allow-all
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate { cloudfront_default_certificate = true }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = { Name = "${var.name_prefix}-reports-cdn" }
}
