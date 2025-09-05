#############################################
# ECS: Celery task + service 
#############################################

# --- Task Definition ---
resource "aws_ecs_task_definition" "celery" {
  family                   = "${var.name_prefix}-celery"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "celery"
      image     = "${var.ecr_repo_url}:${var.celery_tag}" # e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest-celery
      essential = true

      # Non-secret environment (safe to commit)
      environment = [
        # Redis
        { name = "REDIS_HOST", value = var.redis_endpoint },
        { name = "REDIS_PORT", value = tostring(var.redis_port) },
        { name = "REDIS_DB",   value = tostring(var.redis_db) },

        # Database (non-secret bits)
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_USER", value = var.db_user },
        { name = "DB_NAME", value = var.db_name },

        # App settings
        { name = "STAGE",  value = var.mode },                 # dev|stg|prod
        { name = "ENV",    value = var.mode },                 # keep same as STAGE for simplicity
        { name = "ADMIN_EMAIL", value = var.admin_email },
        { name = "S3_BUCKET",    value = var.assets_bucket },
        { name = "CDN_DOMAIN",   value = var.cdn_domain },
        { name = "EMAIL_HOST",   value = var.smtp_host },
        { name = "EMAIL_PORT",   value = tostring(var.smtp_port) },
        { name = "DEFAULT_FROM_EMAIL", value = var.from_email },
        { name = "FRONTEND_BASE_URL", value = var.frontend_url },
        { name = "ADMIN_BASE_URL",    value = var.admin_url },
        { name = "BASE_URL",          value = var.api_url },
        { name = "SENTRY_DSN",        value = var.sentry_dsn },
      ]

      # Secrets (pulled at runtime from AWS Secrets Manager / SSM)
      secrets = [
        { name = "DB_PASSWORD",           valueFrom = var.sm_db_password_arn },
        { name = "EMAIL_HOST_USER",       valueFrom = var.sm_smtp_user_arn },
        { name = "EMAIL_HOST_PASSWORD",   valueFrom = var.sm_smtp_password_arn },
        { name = "KNOCK_KEY",             valueFrom = var.sm_knock_key_arn },
        { name = "SLACK_APP_ID",          valueFrom = var.sm_slack_app_id_arn },
        { name = "SLACK_APP_SECRET",      valueFrom = var.sm_slack_app_secret_arn },
        { name = "SLACK_KNOCK_CHANNEL_ID",valueFrom = var.sm_slack_knock_channel_id_arn },
        { name = "API_VIDEO_KEY",         valueFrom = var.sm_api_video_key_arn },
        { name = "OPENAI_API_KEY",        valueFrom = var.sm_openai_api_key_arn },
        { name = "LAUNCHDARKLY_SDK_KEY",  valueFrom = var.sm_launchdarkly_sdk_key_arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name_prefix}-celery"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "celery"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "pgrep -f 'celery.*worker' || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

# Log group (short retention for demos)
resource "aws_cloudwatch_log_group" "celery" {
  name              = "/ecs/${var.name_prefix}-celery"
  retention_in_days = 7
}

# --- Service ---
resource "aws_ecs_service" "celery" {
  name                   = "${var.name_prefix}-celery"
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.celery.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.ecs_service_sg_id]
  }

  deployment_circuit_breaker { enable = true, rollback = true }
  deployment_controller { type = "ECS" }

  lifecycle { ignore_changes = [task_definition] }
}
