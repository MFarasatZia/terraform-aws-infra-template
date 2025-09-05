# ---- Input (dummy placeholder for portfolio) ----
variable "frontend_api_key" {
  description = "Dummy placeholder for a frontend SDK/API key"
  type        = string
  default     = "dummy-frontend-api-key-123456"
}

# ---- AWS Secrets Manager Example ----
resource "aws_secretsmanager_secret" "frontend_secret" {
  name = "example/frontend/api_key-v1" # <-- safe placeholder name
}

resource "aws_secretsmanager_secret_version" "frontend_secret_version" {
  secret_id     = aws_secretsmanager_secret.frontend_secret.id
  secret_string = var.frontend_api_key
}
