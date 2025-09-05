terraform {
  backend "s3" {
    bucket = "tf-state-example-bucket"    # dummy bucket
    key    = "project/terraform.tfstate"  # dummy state key
    region = "us-east-1"                  # example region
  }
}

module "clear-intent-dev" {
  source = "./clear_intent_dev"

  vpc                   = module.vpc
  https_listener_arn    = aws_lb_listener.clear-intent-lb-https.arn
  mode                  = "dev"
  alias                 = ["api.dev.example.com"]
  frontend_alias        = ["account.dev.example.com"]
  admin_alias           = ["admin.dev.example.com"]
  priority              = 190
  rds_password          = var.rds_password
  account_id            = data.aws_caller_identity.current.account_id
  admin_login           = var.default_admin
  admin_password        = var.default_password
  assertthat_key        = var.assertthat_key
  assertthat_project_id = var.assertthat_project_id
  assertthat_secret     = var.assertthat_secret

  certificate_arn = aws_acm_certificate_validation.clear-intent-certificate.certificate_arn
  slack_webhook   = var.slack_webhook

  access_key         = var.access_key
  secret_key         = var.secret_key
  smtp_user_id       = var.dev_smtp_user
  smtp_user_password = var.dev_smtp_password
  smtp_host          = "smtp.example.com"
  ses_email          = "info@dev.example.com"
  perf_coeff         = 2

  instance_class = "db.t3.micro"

  dsn_url_backend = var.sentry_dsn_backend
  dsn_url_account = var.sentry_dsn_account
  dsn_url_admin   = var.sentry_dsn_admin

  knock_api_key    = var.dev_knock_api_key
  knock_channel_id = var.dev_knock_channel_id
  knock_secret_key = var.dev_knock_secret_key

  slack_app_id           = var.slack_app_id
  slack_app_secret       = var.slack_app_secret
  slack_knock_channel_id = var.slack_knock_channel_id

  bastion_sg       = aws_security_group.bastion_sg.id
  api_video_key_dev = var.api_video_key_dev

  openai_api_key = var.openai_api_key

  launchdarkly_sdk_key_frontend = var.launchdarkly_sdk_key_frontend
  launchdarkly_sdk_key_backend  = var.launchdarkly_sdk_key_backend
  launchdarkly_sdk_key_admin    = var.launchdarkly_sdk_key_admin

  public_subnets = module.vpc.public_subnets
  name           = var.name
  branch         = var.branch

  providers = {
    aws.secondary = aws.secondary
  }
}

module "clear-intent-stg" {
  source = "./clear_intent_stg"

  vpc                   = module.vpc
  https_listener_arn    = aws_lb_listener.clear-intent-lb-https.arn
  mode                  = "staging"
  alias                 = ["api.stg.example.com"]
  frontend_alias        = ["account.stg.example.com"]
  admin_alias           = ["admin.stg.example.com"]
  priority              = 200
  rds_password          = var.rds_password
  account_id            = data.aws_caller_identity.current.account_id
  admin_login           = var.default_admin
  admin_password        = var.default_password
  assertthat_key        = var.assertthat_key
  assertthat_project_id = var.assertthat_project_id
  assertthat_secret     = var.assertthat_secret

  certificate_arn = aws_acm_certificate_validation.clear-intent-certificate.certificate_arn
  slack_webhook   = var.slack_webhook

  access_key         = var.access_key
  secret_key         = var.secret_key
  smtp_user_id       = var.dev_smtp_user
  smtp_user_password = var.dev_smtp_password
  smtp_host          = "smtp.example.com"
  ses_email          = "info@stg.example.com"
  perf_coeff         = 2

  instance_class = "db.t3.micro"

  dsn_url_backend = var.sentry_dsn_backend
  dsn_url_account = var.sentry_dsn_account
  dsn_url_admin   = var.sentry_dsn_admin

  knock_api_key    = var.dev_knock_api_key
  knock_channel_id = var.dev_knock_channel_id
  knock_secret_key = var.dev_knock_secret_key

  slack_app_id           = var.slack_app_id
  slack_app_secret       = var.slack_app_secret
  slack_knock_channel_id = var.slack_knock_channel_id

  bastion_sg   = aws_security_group.bastion_sg.id
  api_video_key = var.api_video_key

  launchdarkly_sdk_key_admin_stg    = var.launchdarkly_sdk_key_admin_stg
  launchdarkly_sdk_key_backend_stg  = var.launchdarkly_sdk_key_backend_stg
  launchdarkly_sdk_key_frontend_stg = var.launchdarkly_sdk_key_frontend_stg
  openai_api_key                    = var.openai_api_key

  providers = {
    aws.secondary = aws.secondary
  }
}

module "clear-intent-prod" {
  source = "./clear_intent_prod"

  vpc                   = module.vpc
  https_listener_arn    = aws_lb_listener.clear-intent-lb-https.arn
  mode                  = "prod"
  alias                 = ["api.example.com"]
  frontend_alias        = ["account.example.com"]
  admin_alias           = ["admin.example.com"]
  priority              = 180
  rds_password          = var.rds_password
  account_id            = data.aws_caller_identity.current.account_id
  admin_login           = var.default_admin
  admin_password        = var.default_password
  assertthat_key        = var.assertthat_key
  assertthat_project_id = var.assertthat_project_id
  assertthat_secret     = var.assertthat_secret

  certificate_arn = aws_acm_certificate_validation.clear-intent-certificate.certificate_arn
  slack_webhook   = var.slack_webhook

  access_key         = var.access_key
  secret_key         = var.secret_key
  smtp_user_id       = "resend"                 # example sender id
  smtp_user_password = var.resend_api_key
  smtp_host          = "smtp.example.com"       # sanitized
  ses_email          = "info@example.com"

  dsn_url_backend = var.sentry_dsn_backend
  dsn_url_account = var.sentry_dsn_account
  dsn_url_admin   = var.sentry_dsn_admin

  knock_api_key    = var.dev_knock_api_key
  knock_channel_id = var.dev_knock_channel_id
  knock_secret_key = var.dev_knock_secret_key

  slack_app_id           = var.slack_app_id
  slack_app_secret       = var.slack_app_secret
  slack_knock_channel_id = var.slack_knock_channel_id

  bastion_sg   = aws_security_group.bastion_sg.id
  api_video_key = var.api_video_key

  launchdarkly_sdk_key_frontend_production = var.launchdarkly_sdk_key_frontend_production
  launchdarkly_sdk_key_backend_production  = var.launchdarkly_sdk_key_backend_production
  launchdarkly_sdk_key_admin_production    = var.launchdarkly_sdk_key_admin_production
  openai_api_key                           = var.openai_api_key

  providers = {
    aws.secondary = aws.secondary
  }
}

# module "storybook-feature-branch" {
#   source = "./storybook-feature-branch"
#   account_id = data.aws_caller_identity.current.account_id
#   repo_url   = var.storybook_feature_git_url
# }
