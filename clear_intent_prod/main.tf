terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.virginia]
    }
  }
}

# --------------------------
# Backend stack (sanitized)
# --------------------------
module "backend" {
  source = "./backend"

  branch                 = var.mode
  mode                   = var.mode
  name                   = "example-app-${var.mode}"      # was: clear-intent-${var.mode}
  alias                  = var.alias
  priority               = var.priority
  instance_class         = var.instance_class
  vpc                    = var.vpc
  rds_password           = var.rds_password
  https_listener_arn     = var.https_listener_arn
  account_id             = var.account_id
  admin_login            = var.admin_login
  admin_password         = var.admin_password
  admin_url              = var.admin_alias[0]
  assertthat_key         = var.assertthat_key
  assertthat_project_id  = var.assertthat_project_id
  assertthat_secret      = var.assertthat_secret
  ses_email              = var.ses_email
  frontend_url           = var.frontend_alias[0]
  smtp_host              = var.smtp_host
  smtp_user_id           = var.smtp_user_id
  smtp_user_password     = var.smtp_user_password
  knock_secret_key       = var.knock_secret_key
  slack_webhook          = var.slack_webhook
  slack_app_id           = var.slack_app_id
  slack_app_secret       = var.slack_app_secret
  slack_knock_channel_id = var.slack_knock_channel_id
  perf_coeff             = var.perf_coeff
  dsn_url                = var.dsn_url_backend
  bastion_sg             = var.bastion_sg
  api_video_key_dev          = var.api_video_key_dev
  launchdarkly_sdk_key_backend = var.launchdarkly_sdk_key_backend
  openai_api_key = var.openai_api_key
  vpc_id         = var.vpc.vpc_id
}

# --------------------------
# Frontend stack (sanitized)
# --------------------------
module "frontend" {
  source = "./frontend"

  account_id = var.account_id
  aliases    = var.frontend_alias
  mode       = var.mode
  branch     = var.mode

  assertthat_key        = var.assertthat_key
  assertthat_project_id = var.assertthat_project_id
  assertthat_secret     = var.assertthat_secret

  access_key = var.access_key
  secret_key = var.secret_key
  base_url   = "https://${var.alias[0]}"

  knock_api_key    = var.knock_api_key
  knock_channel_id = var.knock_channel_id
  slack_webhook    = var.slack_webhook
  dsn_url          = var.dsn_url_account

  launchdarkly_sdk_key_frontend = var.launchdarkly_sdk_key_frontend

  providers = {
    aws.virginia = aws.virginia
  }
}

# --------------------------
# Admin stack (sanitized)
# --------------------------
module "admin" {
  source = "./admin"

  account_id = var.account_id
  aliases    = var.admin_alias
  mode       = var.mode
  branch     = var.mode

  assertthat_key        = var.assertthat_key
  assertthat_project_id = var.assertthat_project_id
  assertthat_secret     = var.assertthat_secret

  access_key = var.access_key
  secret_key = var.secret_key
  base_url   = "https://${var.alias[0]}"

  knock_api_key    = var.knock_api_key
  knock_channel_id = var.knock_channel_id
  slack_webhook    = var.slack_webhook
  dsn_url          = var.dsn_url_admin

  launchdarkly_sdk_key_admin = var.launchdarkly_sdk_key_admin

  providers = {
    aws.virginia = aws.virginia
  }
}

# Optional Storybook stack (kept commented; sanitized alias)
# module "storybook" {
#   source      = "./storybook"
#   count       = var.mode == "dev" ? 1 : 0
#   account_id  = var.account_id
#   aliases     = ["components.example.com"]
#   mode        = var.mode
#   branch      = var.mode
#   slack_webhook = var.slack_webhook
#
#   access_key = var.access_key
#   secret_key = var.secret_key
#
#   certificate_arn = var.certificate_arn
#
#   providers = {
#     aws.virginia = aws.virginia
#   }
# }
