#############################################
# S3 static storage + CloudFront (safe & concise)
#############################################

variable "name_prefix"   { type = string, default = "demo" }  # project/app name
variable "env"           { type = string, default = "dev" }   # dev|stg|prod
variable "allowed_origins" {
  type        = list(string)
  default     = ["*"]  # tighten to your domains in real use
  description = "CORS allowed origins for GET/HEAD"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# --- S3 bucket (private, BOE) ---
resource "aws_s3_bucket" "storage" {
  bucket = "${var.name_prefix}-storage-${var.env}-${random_string.suffix.result}"
  tags   = { Name = "${var.name_prefix}-storage-${var.env}" }
}

resource "aws_s3_bucket_ownership_controls" "storage" {
  bucket = aws_s3_bucket.storage.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_cors_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# --- CloudFront OAI + bucket policy (read-only via CDN) ---
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.name_prefix}-storage-${var.env}-oai"
}

locals { s3_origin_id = "${var.name_prefix}-storage-origin" }

data "aws_iam_policy_document" "storage_read_for_oai" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.storage.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "storage" {
  bucket = aws_s3_bucket.storage.id
  policy = data.aws_iam_policy_document.storage_read_for_oai.json
}

# --- CloudFront distribution (default cert) ---
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.storage.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      headers      = ["Origin"] # keep if you rely on CORS/Origin
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

  tags = { Environment = var.env }
}

# --- Helpful outputs ---
output "storage_bucket_name"   { value = aws_s3_bucket.storage.bucket }
output "cdn_domain_name"       { value = aws_cloudfront_distribution.cdn.domain_name }
