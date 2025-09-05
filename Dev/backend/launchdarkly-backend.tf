#############################################
# Secrets Manager: LaunchDarkly SDK (Safe)
#############################################

variable "name_prefix" { type = string, default = "demo" }

# Optional: bring your own KMS key (leave empty to use AWS managed key for Secrets Manager)
variable "kms_key_id" { type = string, default = "" }

# Never commit the real secret; pass via tfvars/CI if you want TF to set it.
variable "ld_backend_secret_value" {
  type      = string
  default   = ""
  sensitive = true
}

# If true and a value is provided, Terraform will write the initial version.
variable "create_initial_secret_version" {
  type    = bool
  default = false
}

resource "aws_secretsmanager_secret" "ld_backend" {
  name                    = "${var.name_prefix}/launchdarkly/sdk_key/backend"
  description             = "LaunchDarkly SDK key (backend) for ${var.name_prefix}"
  kms_key_id              = var.kms_key_id != "" ? var.kms_key_id : null
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-ld-backend"
  }
}

# Optional initial value — only created if explicitly enabled and value provided
resource "aws_secretsmanager_secret_version" "ld_backend" {
  count         = var.create_initial_secret_version && var.ld_backend_secret_value != "" ? 1 : 0
  secret_id     = aws_secretsmanager_secret.ld_backend.id
  secret_string = var.ld_backend_secret_value
}
