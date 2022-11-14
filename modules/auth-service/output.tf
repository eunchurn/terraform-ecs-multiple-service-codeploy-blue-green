output "auth_endpoint" {
  value = module.auth-alb.route53.fqdn
}

output "auth_ecs_security_group_id" {
  value = module.auth-sg.ecs_security_group.id
}
