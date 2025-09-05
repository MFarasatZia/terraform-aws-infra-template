variable "name_prefix"               { type = string, default = "demo-app" }
variable "aws_region"                { type = string, default = "us-east-1" }
variable "account_id"                { type = string }
variable "mode"                      { type = string, default = "dev" }   # dev|stg|prod
variable "codebuild_service_role_arn"{ type = string }
variable "kms_artifacts_key_arn"     { type = string, default = "" }      # optional
variable "cache_bucket"              { type = string }                     # S3 bucket name (for cache)

# ECR / image
variable "image_repo_name" { type = string }       # e.g., "app-backend"

# Reports (replaces hardcoded bucket/distribution)
variable "report_bucket" { type = string }
variable "report_domain" { type = string }

# DB non-secret bits
variable "app_d_
variable "name_prefix"          { type = string, default = "demo-app" }
variable "codedeploy_role_arn"  { type = string }  # IAM role for CodeDeploy
variable "codedeploy_config_name" { type = string, default = "CodeDeployDefault.ECSAllAtOnce" }

variable "ecs_cluster_name"     { type = string }  # e.g., "demo-ecs"
variable "ecs_service_name"     { type = string }  # e.g., "demo-service"

variable "https_listener_arn"   { type = string }  # ALB HTTPS listener ARN
variable "blue_tg_name"         { type = string }  # ALB target group name (blue)
variable "green_tg_name"        { type = string }  # ALB target group name (green)
variable "name_prefix"                 { type = string, default = "demo-app" }
variable "artifact_bucket"             { type = string }      # S3 bucket for pipeline artifacts
variable "kms_artifacts_key_arn"       { type = string, default = "" }  # optional

# IAM role for Pipeline
variable "codepipeline_role_arn"       { type = string }

# GitHub source
variable "repo_owner"                  { type = string }      # e.g., "your-org"
variable "repo_name"                   { type = string }      # e.g., "your-repo"
variable "branch"                      { type = string, default = "main" }

# Build
variable "codebuild_project_name"      { type = string }      # e.g., aws_codebuild_project.app.name

# Deploy (CodeDeploy to ECS)
variable "codedeploy_app_name"         { type = string }      # e.g., aws_codedeploy_app.ecs.name
variable "codedeploy_deployment_group_name" { type = string } # e.g., aws_codedeploy_deployment_group.ecs.deployment_group_name

variable "ecr_repo_name" {
  type        = string
  default     = "demo-app"
  description = "ECR repository name"
}
variable "cluster_name" {
  type        = string
  default     = "demo-cluster"
  description = "ECS cluster name"
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights"
}
# General
variable "aws_region"      { type = string, default = "us-east-1" }
variable "service_name"    { type = string, default = "demo-app" }
variable "mode"            { type = string, default = "dev" }
variable "perf_coeff"      { type = number, default = 1 }

# Roles
variable "ecs_execution_role_arn" { type = string }
variable "ecs_task_role_arn"      { type = string }

# Image
variable "ecr_repo_url" { type = string }                 # e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/app
variable "image_tag"    { type = string, default = "latest" }

# Networking / cluster / LB
variable "ecs_cluster_id"    { type = string }
variable "service_subnet_ids"{ type = list(string) }
variable "ecs_service_sg_id" { type = string }
variable "assign_public_ip"  { type = bool, default = true }   # set false for private subnets + NAT
variable "target_group_arn"  { type = string }
variable "desired_count"     { type = number, default = 1 }

# DB / Redis (non-secret)
variable "db_host" { type = string }
variable "db_port" { type = number, default = 5432 }
variable "db_user" { type = string,  default = "postgres" }
variable "db_name" { type = string,  default = "app" }

variable "redis_host" { type = string }
variable "redis_port" { type = number, default = 6379 }
variable "redis_db"   { type = number, default = 0 }

# URLs / email (non-secret)
variable "frontend_url" { type = string }                  # https://app.dev.example.com
variable "admin_url"    { type = string }                  # https://admin.dev.example.com
variable "api_url"      { type = string }                  # https://api.dev.example.com
variable "sentry_dsn"   { type = string, default = "" }
variable "from_email"   { type = string }                  # no-reply@dev.example.com
variable "smtp_host"    { type = string }
variable "smtp_port"    { type = number, default = 587 }
variable "assets_bucket"{ type = string }
variable "cdn_domain"   { type = string }

# Secrets (pass ARNs)
variable "sm_db_password_arn"            { type = string }
variable "sm_smtp_user_arn"              { type = string }
variable "sm_smtp_password_arn"          { type = string }
variable "sm_knock_key_arn"              { type = string }
variable "sm_slack_app_id_arn"           { type = string }
variable "sm_slack_app_secret_arn"       { type = string }
variable "sm_slack_knock_channel_id_arn" { type = string }
variable "sm_api_video_key_arn"          { type = string }
variable "sm_openai_api_key_arn"         { type = string }
variable "sm_launchdarkly_sdk_key_arn"   { type = string }
variable "name_prefix"           { type = string, default = "demo" }

# S3 ARNs
variable "cache_bucket_arn"      { type = string }                 # e.g., aws_s3_bucket.codebuild_cache.arn
variable "artifact_bucket_arn"   { type = string }                 # e.g., aws_s3_bucket.artifacts.arn
variable "report_bucket_arn"     { type = string, default = "" }   # optional

# ECR repositories this project can push/pull (list of ARNs)
variable "ecr_repository_arns"   { type = list(string), default = [] }

# Optional KMS key for artifacts encryption
variable "kms_artifacts_key_arn" { type = string, default = "" }

# Optional Secrets Manager secrets used in build env (list of ARNs)
variable "secrets_manager_arns"  { type = list(string), default = [] }
variable "name_prefix"            { type = string, default = "demo-app" }

# S3 artifacts bucket used by CodePipeline/CodeDeploy for AppSpec/TaskDef
variable "artifact_bucket_arn"    { type = string }

# Optional KMS key used to encrypt artifacts in S3
variable "kms_artifacts_key_arn"  { type = string, default = "" }

# Roles that Codedeploy will pass to ECS task sets
# (provide full ARNs; usually one execution role and one task role)
variable "ecs_execution_role_arns" { type = list(string), default = [] }
variable "ecs_task_role_arns"      { type = list(string), default = [] }
variable "name_prefix"                 { type = string, default = "demo-app" }

# S3 artifacts
variable "artifact_bucket_arn"         { type = string }
variable "kms_artifacts_key_arn"       { type = string, default = "" }   # optional

# CodeBuild projects used by the pipeline (list of ARNs; often just one)
variable "codebuild_project_arns"      { type = list(string), default = [] }

# CodeDeploy app & deployment group (ARNs)
variable "codedeploy_app_arn"          { type = string }
variable "codedeploy_deployment_group_arn" { type = string }

# CodeStar connection (GitHub)
variable "codestar_connection_arn"     { type = string }

# ECS roles that deployments will pass to tasks
variable "ecs_execution_role_arns"     { type = list(string), default = [] }
variable "ecs_task_role_arns"          { type = list(string), default = [] }
variable "name_prefix" {
  type        = string
  default     = "demo"
  description = "Prefix for IAM role names"
}
variable "name_prefix"   { type = string, default = "demo" }      # e.g., project/env
variable "service_name"  { type = string, default = "app" }

# If your task pulls secrets at runtime, list only those ARNs (can be empty [])
variable "secrets_manager_secret_arns" {
  type    = list(string)
  default = []
}

# If using SSM Parameter Store, list only the parameter ARNs (can be empty [])
variable "ssm_parameter_arns" {
  type    = list(string)
  default = []
}

# If the app needs to invoke Lambdas, list their ARNs (can be empty [])
variable "lambda_invoke_arns" {
  type    = list(string)
  default = []
}
variable "service_name"        { type = string, default = "demo-app" }
variable "vpc_id"              { type = string }
variable "https_listener_arn"  { type = string }
variable "listener_priority"   { type = number, default = 100 }
variable "hostnames"           { type = list(string) }      # e.g., ["api.dev.example.com"]

variable "tg_port"             { type = number, default = 8000 }
variable "health_check_path"   { type = string, default = "/api/common/health-check/" }
variable "deregistration_delay"{ type = number, default = 30 }
variable "name_prefix"           { type = string, default = "demo" }
variable "service_name"          { type = string, default = "app" }
variable "vpc_id"                { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "alb_sg_id"             { type = string }                 # ALB security group id
variable "bastion_sg_id"         { type = string, default = "" }   # optional
variable "app_port"              { type = number, default = 8000 }

# RDS
variable "db_instance_class"     { type = string, default = "db.t4g.micro" }
variable "db_engine_version"     { type = string, default = "15.5" }
variable "db_allocated_storage"  { type = number, default = 20 }
variable "db_multi_az"           { type = bool,   default = false }
variable "db_backup_retention_days" { type = number, default = 7 }
variable "db_deletion_protection"   { type = bool,   default = false }  # true for prod
variable "db_skip_final_snapshot"   { type = bool,   default = true }   # false for prod
variable "db_username"           { type = string,  default = "postgres" }
variable "db_password"           { type = string,  sensitive = true }
variable "name_prefix"         { type = string, default = "demo-dev" }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }

# App SG that should be allowed to access Redis
variable "app_sg_id"           { type = string }

# Redis config
variable "redis_port"          { type = number, default = 6379 }
variable "redis_engine_version"{ type = string, default = "7.x" }      # or "6.x"
variable "redis_node_type"     { type = string, default = "cache.t3.micro" }
variable "redis_node_count"    { type = number, default = 1 }          # demo only
variable "redis_parameter_group"{ type = string, default = "default.redis7" } # or "default.redis6.x"
