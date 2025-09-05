resource "aws_lb" "app_alb" {
  name                             = "app-alb-example"
  subnets                          = module.vpc.public_subnets
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  internal                         = false
  security_groups                  = [aws_security_group.app_alb_sg.id]
  idle_timeout                     = 400
}

resource "aws_security_group" "app_alb_sg" {
  name        = "app-alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for public ALB (HTTP/HTTPS)"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "app_alb_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_listener" "app_alb_https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # example policy
  certificate_arn   = aws_acm_certificate_validation.app_certificate.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No matching listener rule."
      status_code  = "200"
    }
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}
