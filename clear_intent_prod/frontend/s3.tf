#############################################
# CodeBuild S3 Buckets (Concise, Safe)
#############################################

variable "name_prefix" {
  description = "Prefix for resource names (e.g., demo-feature)"
  type        = string
  default     = "demo-feature"
}

# Reuse one suffix to keep names related
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

# -------- Cache bucket (private) --------
resource "aws_s3_bucket" "codebuild_cache" {
  bucket = "${var.name_prefix}-codebuild-cache-${random_string.suffix.result}"
  tags   = { Name = "${var.name_prefix}-codebuild-cache" }
}

resource "aws_s3_bucket_ownership_controls" "codebuild_cache" {
  bucket = aws_s3_bucket.codebuild_cache.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "codebuild_cache" {
  depends_on = [aws_s3_bucket_ownership_controls.codebuild_cache]
  bucket     = aws_s3_bucket.codebuild_cache.id
  acl        = "private"
}

# -------- Artifacts bucket (private, auto-clean) --------
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.name_prefix}-artifacts-${random_string.suffix.result}"
  force_destroy = true
  tags          = { Name = "${var.name_prefix}-artifacts" }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "clean-up"
    status = "Enabled"

    # All objects
    filter {}
    expiration { days = 30 }
  }
}

resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "artifacts" {
  depends_on = [aws_s3_bucket_ownership_controls.artifacts]
  bucket     = aws_s3_bucket.artifacts.id
  acl        = "private"
}
