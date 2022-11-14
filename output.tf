output "api_endpoint" {
  value = module.api.api_endpoint
}

output "auth_endpoint" {
  value = module.auth.auth_endpoint
}

output "s3_bucket_id" {
  value = module.storage.assets_bucket_id
}

output "s3_access_key" {
  value = module.iam-user.access_key
}

output "ecs_api_task_id" {
  value = module.api.ecs_api_task_id.id
}

output "ecs_api_task_revision" {
  value = module.api.ecs_api_task_id.revision
}
