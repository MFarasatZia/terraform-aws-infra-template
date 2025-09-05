#############################################
# ALB Target Groups (Blue / Green)
#############################################

# NOTE: TG names must be ≤32 chars. We append a tiny UUID slice for uniqueness.
resource "aws_lb_target_group" "blue" {
  name                 = "${var.service_name}-blue-${substr(uuid(), 0, 3)}"
  port                 = var.tg_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    interval            = 30
    path                = var.health_check_path
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_target_group" "green" {
  name                 = "${var.service_name}-green-${substr(uuid(), 0, 3)}"
  port                 = var.tg_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    interval            = 30
    path                = var.health_check_path
    timeout             = 5
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

#############################################
# Listener Rule → forward to BLUE (initial)
#############################################

resource "aws_lb_listener_rule" "app" {
  listener_arn = var.https_listener_arn
  priority     = var.listener_priority

  # Start by routing to BLUE. (CodeDeploy or your process can later swap to GREEN.)
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  # Allow external deployment tools (e.g., CodeDeploy) to mutate the target group
  lifecycle {
    ignore_changes = [
      action[0].target_group_arn,
      action[0].forward
    ]
  }

  condition {
    host_header { values = var.hostnames }
  }
}
