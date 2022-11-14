output "aws_target_group" {
  value = aws_alb_target_group.alb_auth_target_group
}

output "alb_auth_listener" {
  value = aws_alb_listener.auth_application_internal
}

output "route53" {
  value = aws_route53_record.platform_sub
}
