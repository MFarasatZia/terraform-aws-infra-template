#############################################
# CodeDeploy for ECS (Blue/Green) 
#############################################

# App
resource "aws_codedeploy_app" "ecs" {
  name             = "${var.name_prefix}-ecs"
  compute_platform = "ECS"
}

# Deployment Group
resource "aws_codedeploy_deployment_group" "ecs" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "${var.name_prefix}-dg"
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = var.codedeploy_config_name  # e.g., CodeDeployDefault.ECSAllAtOnce

  # Roll back on failures
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # Blue/Green settings
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # ECS service to update
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  # ALB listener + target groups (blue/green)
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.https_listener_arn]
      }
      target_group { name = var.blue_tg_name }
      target_group { name = var.green_tg_name }
    }
  }
}
