# SES domain identity for main domain
resource "aws_ses_domain_identity" "main_domain" {
  domain = "example.com"
}

resource "aws_ses_domain_dkim" "main_domain" {
  domain = aws_ses_domain_identity.main_domain.domain
}

# SES domain identity for dev domain
resource "aws_ses_domain_identity" "dev_domain" {
  domain = "dev.example.com"
}

resource "aws_ses_domain_dkim" "dev_domain" {
  domain = aws_ses_domain_identity.dev_domain.domain
}

# Policy document for SES send access
data "aws_iam_policy_document" "ses_send_access" {
  statement {
    effect = "Allow"

    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]

    resources = ["*"]
  }
}

# IAM user for SES
resource "aws_iam_user" "ses_user" {
  name = "dummy_ses_user"
}

resource "aws_iam_access_key" "ses_user_key" {
  user = aws_iam_user.ses_user.name
}

resource "aws_iam_user_policy" "ses_user_policy" {
  name_prefix = "SESSendOnlyAccess"
  user        = aws_iam_user.ses_user.name
  policy      = data.aws_iam_policy_document.ses_send_access.json
}
