# ---- AWS Region ----
variable "AWS_REGION" {
  description = "AWS region for deployments"
  type        = string
  default     = "us-east-1"
}

# ---- GitHub Repository Metadata ----
variable "repo_owner" {
  description = "GitHub Organization or Username"
  type        = string
  default     = "example-org"
}

variable "repo_name" {
  description = "GitHub repository name of the application to deploy"
  type        = string
  default     = "example-frontend-app"
}

variable "branch" {
  description = "GitHub branch to build and deploy (e.g., main)"
  type        = string
  default     = "main"
}

# ---- App Mode ----
variable "mode" {
  description = "Mode of the app (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ---- AWS Account ----
variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "123456789012"
}

# ---- CloudFront Aliases ----
variable "aliases" {
  description = "Aliases the CloudFront distribution should handle"
  type        = list(string)
  default     = ["app.example.com", "www.example.com"]
}

# ---- AWS Credentials (use env vars in real deployments) ----
variable "access_key" {
  description = "AWS access key (dummy placeholder)"
  type        = string
  default     = "DUMMYACCESSKEY12345"
}

variable "secret_key" {
  description = "AWS secret key (dummy placeholder)"
  type        = string
  default     = "dummy/secret/key/replace-me"
}

# ---- Base URL ----
variable "base_url" {
  description = "Base URL for the application"
  type        = string
  default     = "https://api.example.com"
}

# ---- 3rd Party Integrations (all dummy placeholders) ----
variable "assertthat_project_id" {
  description = "Jira Integration Project ID (dummy)"
  type        = string
  default     = "project-12345"
}

variable "assertthat_key" {
  description = "Jira Integration API Key (dummy)"
  type        = string
  default     = "jira-api-key-xxxx"
}

variable "assertthat_secret" {
  description = "Jira Integration API Secret (dummy)"
  type        = string
  default     = "jira-api-secret-xxxx"
}

variable "knock_api_key" {
  description = "Knock API key (dummy)"
  type        = string
  default     = "knock-api-key-xxxx"
}

variable "knock_channel_id" {
  description = "Knock Channel ID (dummy)"
  type        = string
  default     = "channel-12345"
}

variable "slack_webhook" {
  description = "Slack webhook URL (dummy)"
  type        = string
  default     = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
}

variable "dsn_url" {
  description = "Sentry DSN URL (dummy)"
  type        = string
  default     = "https://examplePublicKey@o0.ingest.sentry.io/0"
}

variable "launchdarkly_sdk_key_frontend" {
  description = "Frontend SDK key (dummy)"
  type        = string
  sensitive   = true
  default     = "sdk-dummy-frontend-key-123456"
}
