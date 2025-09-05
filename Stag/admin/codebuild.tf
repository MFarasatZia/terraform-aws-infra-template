#############################################
# CodeBuild (for CodePipeline)
#############################################

resource "aws_codebuild_project" "app" {
  name           = "${var.name_prefix}-docker-build"
  description    = "${var.name_prefix} docker build"
  build_timeout  = 30
  service_role   = var.codebuild_service_role_arn
  encryption_key = var.kms_artifacts_key_arn # optional KMS key/alias ARN

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.cache_bucket
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Plain (non-secret) params
    environment_variable { name = "AWS_DEFAULT_REGION" value = var.aws_region }
    environment_variable { name = "AWS_ACCOUNT_ID"     value = var.account_id }
    environment_variable { name = "IMAGE_REPO_NAME"    value = var.image_repo_name }
    environment_variable { name = "MODE"               value = var.mode }
    environment_variable { name = "REPORT_BUCKET"      value = var.report_bucket }
    environment_variable { name = "REPORT_DOMAIN"      value = var.report_domain }
    environment_variable { name = "PORT"               value = "5432" }
    environment_variable { name = "HOST"               value = "localhost" }
    environment_variable { name = "NAME"               value = var.app_db_name }
    environment_variable { name = "USER"               value = var.app_db_user }

    # Secrets (use Secrets Manager refs like "secret-id:json-key")
    environment_variable { name = "RDS_PASSWORD"            type = "SECRETS_MANAGER" value = var.sm_rds_password }
    environment_variable { name = "ASSERTTHAT_PROJECT_ID"   type = "SECRETS_MANAGER" value = var.sm_assertthat_project_id }
    environment_variable { name = "ASSERTTHAT_KEY"          type = "SECRETS_MANAGER" value = var.sm_assertthat_key }
    environment_variable { name = "ASSERTTHAT_SECRET"       type = "SECRETS_MANAGER" value = var.sm_assertthat_secret }
    environment_variable { name = "SLACK_INCOMING_WEBHOOK"  type = "SECRETS_MANAGER" value = var.sm_slack_webhook }
    environment_variable { name = "LAUNCHDARKLY_SDK_KEY"    type = "SECRETS_MANAGER" value = var.sm_ld_backend_key }
  }

  # CodePipeline supplies the source; buildspec lives in repo
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
#############################################
# CodeBuild (for CodePipeline)
#############################################

resource "aws_codebuild_project" "app" {
  name           = "${var.name_prefix}-docker-build"
  description    = "${var.name_prefix} docker build"
  build_timeout  = 30
  service_role   = var.codebuild_service_role_arn
  encryption_key = var.kms_artifacts_key_arn # optional KMS key/alias ARN

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.cache_bucket
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Plain (non-secret) params
    environment_variable { name = "AWS_DEFAULT_REGION" value = var.aws_region }
    environment_variable { name = "AWS_ACCOUNT_ID"     value = var.account_id }
    environment_variable { name = "IMAGE_REPO_NAME"    value = var.image_repo_name }
    environment_variable { name = "MODE"               value = var.mode }
    environment_variable { name = "REPORT_BUCKET"      value = var.report_bucket }
    environment_variable { name = "REPORT_DOMAIN"      value = var.report_domain }
    environment_variable { name = "PORT"               value = "5432" }
    environment_variable { name = "HOST"               value = "localhost" }
    environment_variable { name = "NAME"               value = var.app_db_name }
    environment_variable { name = "USER"               value = var.app_db_user }

    # Secrets (use Secrets Manager refs like "secret-id:json-key")
    environment_variable { name = "RDS_PASSWORD"            type = "SECRETS_MANAGER" value = var.sm_rds_password }
    environment_variable { name = "ASSERTTHAT_PROJECT_ID"   type = "SECRETS_MANAGER" value = var.sm_assertthat_project_id }
    environment_variable { name = "ASSERTTHAT_KEY"          type = "SECRETS_MANAGER" value = var.sm_assertthat_key }
    environment_variable { name = "ASSERTTHAT_SECRET"       type = "SECRETS_MANAGER" value = var.sm_assertthat_secret }
    environment_variable { name = "SLACK_INCOMING_WEBHOOK"  type = "SECRETS_MANAGER" value = var.sm_slack_webhook }
    environment_variable { name = "LAUNCHDARKLY_SDK_KEY"    type = "SECRETS_MANAGER" value = var.sm_ld_backend_key }
  }

  # CodePipeline supplies the source; buildspec lives in repo
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
#############################################
# CodeBuild (for CodePipeline)
#############################################

resource "aws_codebuild_project" "app" {
  name           = "${var.name_prefix}-docker-build"
  description    = "${var.name_prefix} docker build"
  build_timeout  = 30
  service_role   = var.codebuild_service_role_arn
  encryption_key = var.kms_artifacts_key_arn # optional KMS key/alias ARN

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.cache_bucket
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Plain (non-secret) params
    environment_variable { name = "AWS_DEFAULT_REGION" value = var.aws_region }
    environment_variable { name = "AWS_ACCOUNT_ID"     value = var.account_id }
    environment_variable { name = "IMAGE_REPO_NAME"    value = var.image_repo_name }
    environment_variable { name = "MODE"               value = var.mode }
    environment_variable { name = "REPORT_BUCKET"      value = var.report_bucket }
    environment_variable { name = "REPORT_DOMAIN"      value = var.report_domain }
    environment_variable { name = "PORT"               value = "5432" }
    environment_variable { name = "HOST"               value = "localhost" }
    environment_variable { name = "NAME"               value = var.app_db_name }
    environment_variable { name = "USER"               value = var.app_db_user }

    # Secrets (use Secrets Manager refs like "secret-id:json-key")
    environment_variable { name = "RDS_PASSWORD"            type = "SECRETS_MANAGER" value = var.sm_rds_password }
    environment_variable { name = "ASSERTTHAT_PROJECT_ID"   type = "SECRETS_MANAGER" value = var.sm_assertthat_project_id }
    environment_variable { name = "ASSERTTHAT_KEY"          type = "SECRETS_MANAGER" value = var.sm_assertthat_key }
    environment_variable { name = "ASSERTTHAT_SECRET"       type = "SECRETS_MANAGER" value = var.sm_assertthat_secret }
    environment_variable { name = "SLACK_INCOMING_WEBHOOK"  type = "SECRETS_MANAGER" value = var.sm_slack_webhook }
    environment_variable { name = "LAUNCHDARKLY_SDK_KEY"    type = "SECRETS_MANAGER" value = var.sm_ld_backend_key }
  }

  # CodePipeline supplies the source; buildspec lives in repo
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
