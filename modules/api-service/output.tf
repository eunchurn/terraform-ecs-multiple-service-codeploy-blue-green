output "api_endpoint" {
  value = module.api-alb.route53.fqdn
}

output "api_ecs_security_group_id" {
  value = module.api-sg.ecs_security_group.id
}

output "route53_staged_zone" {
  value = module.api-alb.route53_staged_zone
}

output "certificate" {
  value = module.api-alb.certificate
}

output "ecs_cluster" {
  value = module.api-ecs.api_ecs_cluster_id
}

output "ecs_api_task_id" {
  value = module.api-ecs.api_ecs_task_id
}
