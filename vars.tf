variable "AWS_REGION" {
  default = "us-east-1" # example region
}

variable "rds_password" {
  type        = string
  description = "Odoo database password"
  default     = "dummy_rds_password"
}

variable "access_key" {
  type        = string
  description = "AWS access key"
  default     = "dummy_access_key"
}

variable "secret_key" {
  type        = string
  description = "AWS secret key"
  default     = "dummy_secret_key"
}

variable "default_admin" {
  type        = string
  description = "Default Django admin superuser"
  default     = "dummy_admin"
}

variable "default_password" {
  type        = string
  description = "Default Django admin superuser password"
  default     = "dummy_password"
}

variable "assertthat_project_id" {
  type        = string
  description = "Assert That Jira Integration Project ID"
  default     = "dummy_project_id"
}

variable "assertthat_key" {
  type        = string
  description = "Assert That Jira Integration API Key"
  default     = "dummy_key"
}

variable "assertthat_secret" {
  type        = string
  description = "Assert That Jira Integration API Secret"
  default     = "dummy_secret"
}

variable "storybook_feature_git_url" {
  type        = string
  description = "Storybook Feature authenticated git URL"
  default     = "https://example.com/storybook.git"
}

variable "living_doc_git_url" {
  type        = string
  description = "Living Documentation authenticated git URL"
  default     = "https://example.com/living-docs.git"
}

variable "behave_pro_api_key" {
  type        = string
  description = "Behave Pro API Key"
  default     = "dummy_behave_api_key"
}

variable "github_exiqtive_frontend_token" {
  type        = string
  description = "Github Token For Exiqtive Frontend"
  default     = "dummy_github_token"
}

variable "dev_smtp_user" {
  type    = string
  default = "dummy_dev_smtp_user"
}

variable "dev_smtp_password" {
  type    = string
  default = "dummy_dev_smtp_password"
}

variable "prod_smtp_user" {
  type    = string
  default = "dummy_prod_smtp_user"
}

variable "prod_smtp_password" {
  type    = string
  default = "dummy_prod_smtp_password"
}

variable "dev_api_url" {
  type    = string
  default = "https://dummy.dev.api"
}

variable "dev_base_url" {
  type    = string
  default = "https://dummy.dev"
}

variable "dev_admin_base_url" {
  type    = string
  default = "https://dummy.dev/admin"
}

variable "dev_default_signin_user" {
  type    = string
  default = "dummy_user@dummy.dev"
}

variable "dev_mailtrap_inbox" {
  type    = string
  default = "dummy_mailtrap_inbox"
}

variable "dev_mailtrap_api_key" {
  type    = string
  default = "dummy_mailtrap_api_key"
}

variable "dev_mailtrap_token" {
  type    = string
  default = "dummy_mailtrap_token"
}

variable "dev_mailtrap_account_id" {
  type    = string
  default = "dummy_mailtrap_account"
}

variable "dev_knock_api_key" {
  type        = string
  description = "Knock API key"
  default     = "dummy_knock_api_key"
}

variable "dev_knock_channel_id" {
  type        = string
  description = "Knock Channel ID"
  default     = "dummy_knock_channel"
}

variable "slack_webhook" {
  type    = string
  default = "https://hooks.slack.com/services/dummy"
}

variable "dev_knock_secret_key" {
  type        = string
  description = "Knock Secret key"
  default     = "dummy_knock_secret"
}

variable "slack_app_id" {
  type        = string
  description = "Slack App ID"
  default     = "dummy_slack_app_id"
}

variable "slack_app_secret" {
  type        = string
  description = "Slack App Secret"
  default     = "dummy_slack_secret"
}

variable "slack_knock_channel_id" {
  type        = string
  description = "Slack Channel ID"
  default     = "dummy_slack_channel"
}

variable "sentry_dsn_backend" {
  type        = string
  description = "Sentry DSN (backend)"
  default     = "https://dummy@sentry.io/backend"
}

variable "sentry_dsn_account" {
  type        = string
  description = "Sentry DSN (frontend account)"
  default     = "https://dummy@sentry.io/account"
}

variable "sentry_dsn_admin" {
  type        = string
  description = "Sentry DSN (frontend admin)"
  default     = "https://dummy@sentry.io/admin"
}

variable "resend_api_key" {
  type        = string
  description = "Resend API Key"
  default     = "dummy_resend_api_key"
}

variable "api_video_key" {
  type        = string
  description = "API Video Key"
  default     = "dummy_api_video_key"
}

variable "api_video_key_dev" {
  type        = string
  description = "API Video Key (Dev)"
  default     = "dummy_api_video_key_dev"
}

variable "launchdarkly_sdk_key_backend" {
  description = "LaunchDarkly server-side SDK key for backend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_backend"
}

variable "launchdarkly_sdk_key_frontend" {
  description = "LaunchDarkly client-side SDK key for frontend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_frontend"
}

variable "launchdarkly_sdk_key_admin" {
  description = "LaunchDarkly client-side SDK key for admin"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_admin"
}

variable "launchdarkly_sdk_key_backend_production" {
  description = "LaunchDarkly server-side SDK key for backend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_backend_prod"
}

variable "launchdarkly_sdk_key_frontend_production" {
  description = "LaunchDarkly client-side SDK key for frontend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_frontend_prod"
}

variable "launchdarkly_sdk_key_admin_production" {
  description = "LaunchDarkly client-side SDK key for admin"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_admin_prod"
}

variable "name" {
  type    = string
  default = "dummy-project-name"
}

variable "branch" {
  type    = string
  default = "dummy-branch"
}

variable "launchdarkly_sdk_key_backend_stg" {
  description = "LaunchDarkly server-side SDK key for backend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_backend_stg"
}

variable "launchdarkly_sdk_key_frontend_stg" {
  description = "LaunchDarkly client-side SDK key for frontend"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_frontend_stg"
}

variable "launchdarkly_sdk_key_admin_stg" {
  description = "LaunchDarkly client-side SDK key for admin"
  type        = string
  sensitive   = true
  default     = "dummy_launchdarkly_admin_stg"
}

variable "openai_api_key" {
  description = "Open AI key"
  type        = string
  default     = "dummy_openai_key"
}
