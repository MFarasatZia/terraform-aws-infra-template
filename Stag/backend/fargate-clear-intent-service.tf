#############################################
# ECS Task Definition 
#############################################

resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  cpu                      = 512 * var.perf_coeff
  memory                   = 1024 * var.perf_coeff
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name       = var.service_name
      image      = "${var.ecr_repo_url}:${var.image_tag}"      # e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest
      essential  = true
      stopTimeout = 110

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      # Non-secret env
      environment = [
        # DB (non-secret bits)
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_USER", value = var.db_user },
        { name = "DB_NAME", value = var.db_name },

        # Redis
        { name = "REDIS_HOST", value = var.redis_host },
        { name = "REDIS_PORT", value = tostring(var.redis_port) },
        { name = "REDIS_DB",   value = tostring(var.redis_db) },

        # App
        { name = "STAGE",              value = var.mode },
        { name = "FRONTEND_BASE_URL",  value = var.frontend_url },
        { name = "ADMIN_BASE_URL",     value = var.admin_url },
        { name = "BASE_URL",           value = var.api_url },
        { name = "SENTRY_DSN",         value = var.sentry_dsn },
        { name = "DEFAULT_FROM_EMAIL", value = var.from_email },
        { name = "EMAIL_HOST",         value = var.smtp_host },
        { name = "EMAIL_PORT",         value = tostring(var.smtp_port) },
        { name = "S3_BUCKET",          value = var.assets_bucket },
        { name = "CDN_DOMAIN",         value = var.cdn_domain }
      ]

      # Secrets (Secrets Manager / SSM Param ARNs)
      secrets = [
        { name = "DB_PASSWORD",            valueFrom = var.sm_db_password_arn },
        { name = "EMAIL_HOST_USER",        valueFrom = var.sm_smtp_user_arn },
        { name = "EMAIL_HOST_PASSWORD",    valueFrom = var.sm_smtp_password_arn },
        { name = "KNOCK_KEY",              valueFrom = var.sm_knock_key_arn },
        { name = "SLACK_APP_ID",           valueFrom = var.sm_slack_app_id_arn },
        { name = "SLACK_APP_SECRET",       valueFrom = var.sm_slack_app_secret_arn },
        { name = "SLACK_KNOCK_CHANNEL_ID", valueFrom = var.sm_slack_knock_channel_id_arn },
        { name = "API_VIDEO_KEY",          valueFrom = var.sm_api_video_key_arn },
        { name = "OPENAI_API_KEY",         valueFrom = var.sm_openai_api_key_arn },
        { name = "LAUNCHDARKLY_SDK_KEY",   valueFrom = var.sm_launchdarkly_sdk_key_arn }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -fsS http://localhost:8000/api/common/health-check/ || exit 1"]
        interval    = 15
        retries     = 3
        timeout     = 5
      }

      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
}

#############################################
# ECS Service
#############################################

resource "aws_ecs_service" "app" {
  name                   = var.service_name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_controller { type = "ECS" }
  deployment_circuit_breaker { enable = true, rollback = true }

  network_configuration {
    subnets         = var.service_subnet_ids       # public or private per your design
    security_groups = [var.ecs_service_sg_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = 8000
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}
