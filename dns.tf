resource "aws_acm_certificate" "app_certificate" {
  domain_name = "api.example.com"
  subject_alternative_names = [
    "api.dev.example.com",
    "api.stg.example.com",
    "component.example.com"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "app_certificate" {
  certificate_arn = aws_acm_certificate.app_certificate.arn
  validation_record_fqdns = flatten([
    for item in aws_acm_certificate.app_certificate.domain_validation_options : item.resource_record_name
  ])
}
