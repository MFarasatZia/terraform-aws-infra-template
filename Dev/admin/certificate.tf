terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      # Uses an alias for us-east-1 (needed for CloudFront/ACM)
      configuration_aliases = [aws.virginia]
    }
  }
}

# ---- Inputs (dummy placeholders for portfolio) ----
# Primary domain first, then SANs. Replace with your own when deploying.
variable "aliases" {
  type        = list(string)
  description = "Primary domain as first element; additional SANs after."
  default     = ["app.example.com", "www.example.com", "api.example.com"]
}

# ---- ACM Certificate in us-east-1 (for CloudFront) ----
resource "aws_acm_certificate" "site_cert" {
  domain_name               = var.aliases[0]
  subject_alternative_names = slice(var.aliases, 1, length(var.aliases))
  validation_method         = "DNS"
  provider                  = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "site_cert" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.site_cert.arn

  validation_record_fqdns = flatten([
    for item in aws_acm_certificate.site_cert.domain_validation_options : item.resource_record_name
  ])
}

# ---- Output (placeholder: assumes a CloudFront distro defined elsewhere) ----
# Update the resource name if your actual CloudFront resource name differs.
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
