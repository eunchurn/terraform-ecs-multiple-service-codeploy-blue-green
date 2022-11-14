# Application Load Balancer
resource "aws_alb" "alb_auth_application" {
  name            = "${var.application_name}-auth-${terraform.workspace}-${var.random_id_prefix}-alb"
  internal        = true
  subnets         = flatten(["${var.private_subnet_ids}"])
  security_groups = flatten(["${var.security_groups_ids}", "${var.ecs_security_group.id}", "${var.alb_security_group.id}"])
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.application_name}-auth-${terraform.workspace}-${var.random_id_prefix}-alb"
    Environment = "${terraform.workspace}"
  }
}


resource "aws_alb_listener" "auth_application_internal" {
  load_balancer_arn = aws_alb.alb_auth_application.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_alb_target_group.alb_auth_target_group.arn
    type             = "forward"
  }
}


# AWS ALB Target Blue groups/Listener for Blue/Green Deployments
resource "aws_alb_target_group" "alb_auth_target_group" {
  name        = "${var.application_name}-auth-${terraform.workspace}-tg-${var.random_id_prefix}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    path                = "/hello"
    unhealthy_threshold = "2"
  }

  tags = {
    Environment = "${terraform.workspace}-auth"
  }

  depends_on = [aws_alb.alb_auth_application]
}

# Standard route53 DNS record for "mystack" pointing to an ALB

data "aws_route53_zone" "platform" {
  name = var.root_domain
}

data "aws_route53_zone" "platform_sub" {
  name = "${terraform.workspace}.${data.aws_route53_zone.platform.name}"
  depends_on = [
    data.aws_route53_zone.platform, var.certificate
  ]
}

# Sub DNS for Auth

resource "aws_route53_record" "platform_sub" {
  zone_id = data.aws_route53_zone.platform_sub.zone_id
  name    = "auth.${data.aws_route53_zone.platform_sub.name}"
  type    = "A"
  alias {
    name                   = aws_alb.alb_auth_application.dns_name
    zone_id                = aws_alb.alb_auth_application.zone_id
    evaluate_target_health = false
  }
}

