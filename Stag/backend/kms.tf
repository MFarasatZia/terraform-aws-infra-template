#############################################
# KMS key for build artifacts (Concise & Safe)
#############################################

# Use the current account automatically (no hardcoded account_id)
data "aws_caller_identity" "current" {}

# Principals (IAM role ARNs) that may USE the key (encrypt/decrypt)
#   - e.g., CodePipeline role, CodeBuild role
variable "kms_user_role_arns" {
  type        = list(string)
  default     = []
  description = "IAM role ARNs allowed to use the KMS key (encrypt/decrypt)."
}

variable "name_prefix" {
  type        = string
  default     = "demo"
}

# Key policy
data "aws_iam_policy_document" "artifacts_kms" {
  policy_id = "key-default-1"

  # 1) Root of the account gets full admin on this key
  statement {
    sid     = "EnableAccountRootPermissions"
    effect  = "Allow"
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # 2) Allow listed roles to USE the key for typical artifact encryption/decryption
  #    (Encrypt/Decrypt, GenerateDataKey*, re-encrypt, and describe)
  statement {
    sid     = "AllowUseOfKeyForBuildArtifacts"
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = var.kms_user_role_arns
    }
  }
}

resource "aws_kms_key" "artifacts" {
  description         = "KMS key for ${var.name_prefix} artifacts"
  policy              = data.aws_iam_policy_document.artifacts_kms.json
  deletion_window_in_days = 7
  enable_key_rotation = true
  tags = { Name = "${var.name_prefix}-artifacts-kms" }
}

resource "aws_kms_alias" "artifacts" {
  name          = "alias/${var.name_prefix}-artifacts"
  target_key_id = aws_kms_key.artifacts.key_id
}
