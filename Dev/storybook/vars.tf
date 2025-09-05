# -------------------------
# Core / Environment
# -------------------------
variable "AWS_REGION" {
  description = "AWS region for deployments"
  type        = string
  default     = "us-east-1"
}

variable "mode" {
  type        = string
  description = "Mode of the deployment (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "branch" {
  type        = string
  description = "Branch of the GitHub repository (e.g., main)"
  default     = "main"
}

variable "name" {
  type        = string
  description = "Name of the app"
  default     = "example-app"
}

# -------------------------
# Networking / Infra
# -------------------------
variable "vpc" {
  type        = any
  description = "The VPC object from the main app"
}

variable "vpc_id" {
  description = "VPC ID (if passed separately)"
  type        = string
  default     = "vpc-0123456789abcdef0"
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
  default     = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
}

variable "https_listener_arn" {
  type        = string
  description = "The ARN of the HTTPS listener"
  default     = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/example/0000000000000000/1111111111111111"
}

variable "instance_class" {
  type        = string
  description = "DB instance class"
  default     = "db.t3.small"
}

variable "priority" {
  type        = number
  description = "Priority on Load Balancer"
  default     = 100
}

# -------------------------
# Aliases / Domains
# -------------------------
variable "alias" {
  type        = list(string)
  description = "Backend/root aliases"
  default     = ["api.example.com"]
}

variable "frontend_alias" {
  type        = list(string)
  description = "Frontend aliases"
  default     = ["app.example.com", "www.example.com"]
}

variable "admin_alias" {
  type        = list(string)
  description = "Admin aliases"
  default     = ["admin.example.com"]
}

# -------------------------
# Accounts / Credentials (dummy placeholders)
# -------------------------
variable "account_id" {
  type        = string
  description = "AWS Account ID"
  default     = "123456789012"
}

variable "access_key" {
  type        = string
  description = "AWS access key (dummy)"
  default     = "DUMMYACCESSKEY12345"
}

variable "secret_key" {
  type        = string
  description = "AWS secret key (dummy)"
  default     = "dummy/secret/key/replace-me"
}

# -------------------------
# Admin / Auth (dummy)
# -------------------------
variable "admin_login" {
  type        = string
  description = "Admin login username"
  default     = "admin"
}

variable "admin_password" {
  type        = string
  description = "Admin password (dummy)"
  default     = "ChangeMe123!"
}

variable "rds_password" {
  type        = string
  description = "Database admin password (dummy)"
  default     = "DB-ChangeMe123!"
}

# -------------------------
# Email / SES / SMTP (dummy)
# -------------------------
variable "smtp_host" {
  type        = any
  description = "SMTP host (SES)"
  default     = "email-smtp.us-east-1.amazonaws.com"
}

variable "smtp_user_id" {
  type        = string
  description = "SMTP user ID (dummy)"
  default     = "AKIADUMMYSMTPUSER"
}

variable "smtp_user_password" {
  type        = string
  description = "SMTP user password (dummy)"
  default     = "dummy-smtp-password"
}

variable "ses_email" {
  type        = string
  description = "Default email to send from"
  default     = "no-reply@example.com"
}

# -------------------------
# Certificates
# -------------------------
variable "certificate_arn" {
  type        = string
  description = "Certificate ARN"
  default     = ""
}

# -------------------------
# 3rd-Party Integrations (dummy)
# -------------------------
variable "assertthat_project_id" {
  type        = string
  description = "Jira Integration Project ID (dummy)"
  default     = "project-12345"
}

variable "assertthat_key" {
  type        = string
  description = "Jira Integration API Key (dummy)"
  default     = "jira-api-key-xxxx"
}

variable "assertthat_secret" {
  type        = string
  description = "Jira Integration API Secret (dummy)"
  default     = "jira-api-secret-xxxx"
}

variable "knock_api_key" {
  type        = string
  description = "Knock API key (dummy)"
  default     = "knock-api-key-xxxx"
}

variable "knock_channel_id" {
  type        = string
  description = "Knock Channel ID (dummy)"
  default     = "channel-12345"
}

variable "knock_secret_key" {
  type        = string
  description = "Knock Secret key (dummy)"
  default     = "knock-secret-key-xxxx"
}

variable "slack_webhook" {
  type        = string
  description = "Slack webhook URL (dummy)"
  default     = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
}

variable "slack_app_id" {
  type        = string
  description = "Slack App ID (dummy)"
  default     = "A0000000000"
}

variable "slack_app_secret" {
  type        = string
  description = "Slack App Secret (dummy)"
  default     = "slack-app-secret-xxxx"
}

variable "slack_knock_channel_id" {
  type        = string
  description = "Slack Knock channel ID (dummy)"
  default     = "C0000000000"
}

variable "api_video_key_dev" {
  type        = string
  description = "API Video key (dummy)"
  default     = "api-video-key-xxxx"
}

# -------------------------
# Observability (dummy)
# -------------------------
variable "dsn_url_backend" {
  type        = string
  description = "Sentry DSN URL (backend)"
  default     = "https://publicKey@o0.ingest.sentry.io/1"
}

variable "dsn_url_account" {
  type        = string
  description = "Sentry DSN URL (account)"
  default     = "https://publicKey@o0.ingest.sentry.io/2"
}

variable "dsn_url_admin" {
  type        = string
  description = "Sentry DSN URL (admin)"
  default     = "https://publicKey@o0.ingest.sentry.io/3"
}

# -------------------------
# Security Groups / Bastion (dummy)
# -------------------------
variable "bastion_sg" {
  type        = string
  description = "Bastion Security Group ID"
  default     = "sg-0123456789abcdef0"
}

# -------------------------
# LaunchDarkly / Feature Flags (dummy, kept sensitive)
# -------------------------
variable "launchdarkly_sdk_key_backend" {
  description = "Server-side SDK key (dummy)"
  type        = string
  sensitive   = true
  default     = "sdk-backend-dummy-123456"
}

variable "launchdarkly_sdk_key_frontend" {
  description = "Client-side SDK key (dummy)"
  type        = string
  sensitive   = true
  default     = "sdk-frontend-dummy-123456"
}

variable "launchdarkly_sdk_key_admin" {
  description = "Admin client-side SDK key (dummy)"
  type        = string
  sensitive   = true
  default     = "sdk-admin-dummy-123456"
}

# -------------------------
# OpenAI (dummy)
# -------------------------
variable "openai_api_key" {
  description = "OpenAI API key (dummy)"
  type        = string
  default     = "sk-dummy-openai-key-123456"
}

# -------------------------
# GitHub Repo Metadata (sanitized)
# -------------------------
variable "repo_owner" {
  type        = string
  description = "GitHub organization or username"
  default     = "example-org"
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name"
  default     = "example-backend"
}

# -------------------------
# Misc
# -------------------------
variable "perf_coeff" {
  type        = number
  description = "Performance coefficient"
  default     = 1
}
