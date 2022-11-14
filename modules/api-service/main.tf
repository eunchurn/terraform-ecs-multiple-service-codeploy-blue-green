module "codebuild" {
  source = "./codebuild"

  region                         = var.region
  application_name               = var.application_name
  random_id_prefix               = var.random_id_prefix
  buildproject_name              = var.buildproject_name
  ecr_api_repository_url         = module.api-ecs.api_repository_url
  api_repository_name            = module.api-ecs.api_repository_name
  api_container_memory           = var.api_container_memory
  vpc_id                         = var.network.vpc_id
  security_groups_ids            = var.network.security_groups_ids
  ecs_security_group_id          = module.api-sg.ecs_security_group.id
  rds_access_security_group_id   = var.database.aws_rds_access_security_group_ids
  rds_db_security_group_id       = var.database.aws_rds_db_security_group_ids
  subnets_id_1                   = var.network.private_subnet_1
  public_subnet_id_1             = var.network.public_subnet_1
  subnets_id_2                   = var.network.private_subnet_2
  public_subnet_id_2             = var.network.public_subnet_2
  ecs_api_task_defination_family = module.api-ecs.ecs_api_task_defination_family
  DATABASE_URL                   = var.ssm_parameters.DATABASE_URL
  APOLLO_KEY                     = var.ssm_parameters.APOLLO_KEY
  APOLLO_GRAPH_REF               = var.ssm_parameters.APOLLO_GRAPH_REF
  api_endpoint_url               = "https://${module.api-alb.route53.fqdn}"
  ssm_depends_on                 = var.ssm_parameters
  rds_depend_on                  = var.database
}

module "codedeploy" {
  source = "./codedeploy"

  region                      = var.region
  random_id_prefix            = var.random_id_prefix
  ecs_execution_role_arn      = module.api-iam.ecs_execution_role.arn
  ecs_cluster_name            = module.api-ecs.cluster_name
  api_service_name            = module.api-ecs.api_service_name
  aws_target_group_blue_name  = module.api-alb.aws_target_group_blue.name
  aws_target_group_green_name = module.api-alb.aws_target_group_green.name
  api_alb_listener_arn        = module.api-alb.aws_alb_blue_green.arn
  api_alb_test_listener_arn   = module.api-alb.aws_alb_test_blue_green.arn
}

module "codepipeline" {
  source = "./codepipeline"

  region              = var.region
  random_id_prefix    = var.random_id_prefix
  api_pipeline_name   = var.api_pipeline_name
  buildproject_name   = module.codebuild.build_project_name
  api_repository_name = var.ecr_api_repository_name
  cluster_name        = module.api-ecs.cluster_name
  api_service_name    = module.api-ecs.api_service_name
}

# module "auth-ecs" {
#   source = "./modules/auth-ecs"

#   region                   = var.region
#   application_name         = var.application_name
#   random_id_prefix         = random_id.random_id_prefix.hex
#   ecr_auth_repository_name = "${var.ecr_auth_repository_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
# }
module "api-iam" {
  source = "./api-iam"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = var.random_id_prefix
}

module "api-alb" {
  source = "./api-alb"

  application_name    = var.application_name
  region              = var.region
  random_id_prefix    = var.random_id_prefix
  vpc_id              = var.network.vpc_id
  public_subnet_ids   = ["${var.network.public_subnets_id}"]
  security_groups_ids = var.network.security_groups_ids
  ecs_security_group  = module.api-sg.ecs_security_group
  alb_security_group  = module.api-sg.alb_security_group
  root_domain         = var.root_domain
}

module "api-ecs" {
  source = "./api-ecs"

  application_name        = var.application_name
  region                  = var.region
  vpc_id                  = var.network.vpc_id
  random_id_prefix        = var.random_id_prefix
  ecr_api_repository_name = "${var.ecr_api_repository_name}-${terraform.workspace}-${var.random_id_prefix}"
  aws_target_group_blue   = module.api-alb.aws_target_group_blue
  aws_target_group_green  = module.api-alb.aws_target_group_green
  ecs_execution_role      = module.api-iam.ecs_execution_role
  security_groups_ids     = var.network.security_groups_ids
  ecs_security_group      = module.api-sg.ecs_security_group
  private_subnets_ids     = ["${var.network.private_subnets_id}"]
  container_port          = var.api_container_port
  scan_on_push            = var.scan_on_push
  api_container_memory    = var.api_container_memory
  DATABASE_URL            = var.ssm_parameters.DATABASE_URL
  APOLLO_KEY              = var.ssm_parameters.APOLLO_KEY
  APOLLO_GRAPH_REF        = var.ssm_parameters.APOLLO_GRAPH_REF
  S3_ACCESS_KEY_ID        = var.ssm_parameters.S3_ACCESS_KEY_ID
  S3_ACCESS_SECRET_ID     = var.ssm_parameters.S3_ACCESS_SECRET_ID
  IAMPORT_KEY             = var.ssm_parameters.IAMPORT_KEY
  IAMPORT_SECRET_KEY      = var.ssm_parameters.IAMPORT_SECRET_KEY
  API_SECRET              = var.ssm_parameters.API_SECRET
  auth_endpoint           = var.auth_endpoint
  api_endpoint            = module.api-alb.route53.fqdn
  ssm_depends_on          = var.ssm_parameters
  s3_bucket_id            = var.s3_bucket_id
}

module "api-autoscaling" {
  source = "./api-autoscaling"

  application_name   = var.application_name
  region             = var.region
  random_id_prefix   = var.random_id_prefix
  ecs_autoscale_role = module.api-iam.ecs_execution_role
  ecs_cluster_name   = module.api-ecs.cluster_name
  ecs_service_name   = module.api-ecs.api_service_name
}

module "api-sg" {
  source = "./api-sg"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = var.random_id_prefix
  vpc_id           = var.network.vpc_id
  container_port   = var.api_container_port
}
