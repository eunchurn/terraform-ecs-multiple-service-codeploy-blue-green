provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "random_id" "random_id_prefix" {
  byte_length = 2
}

# Terraform state management
# https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
# terraform {
#   backend "s3" {
#     bucket = "mystack-terraform-running-state"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-northeast-2"

#     dynamodb_table = "mystack-terraform-running-locks"
#     encrypt        = true
#   }
# }

// Only use very first `default` workspace state creation
# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "mystack-terraform-running-state"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-northeast-2"
#   }
# }

# module "terraform_state" {
#   source                               = "./modules/terraform-state"
#   s3_terraform_state_bucket_name       = "mystack-terraform-running-state"
#   s3_terraform_state_key               = "global/s3/terraform.tfstate"
#   dynamodb_terraform_state_locks_table = "mystack-terraform-running-locks"
# }

# AWS SSM Paremeter

module "ssm-parameter" {
  source = "./modules/ssm"

  application_name    = var.application_name
  random_id_prefix    = random_id.random_id_prefix.hex
  rds_depend_on       = module.database
  APOLLO_KEY          = var.APOLLO_KEY
  APOLLO_GRAPH_REF    = "${var.APOLLO_GRAPH_REF}stage-${terraform.workspace}"
  S3_ACCESS_KEY_ID    = module.iam-user.access_key
  S3_ACCESS_SECRET_ID = module.iam-user.access_secret_key
  IAMPORT_KEY         = var.IAMPORT_KEY
  IAMPORT_SECRET_KEY  = var.IAMPORT_SECRET_KEY
  API_SECRET          = var.API_SECRET
  KAKAO_KEY           = var.KAKAO_KEY
}

module "networks" {
  source               = "./modules/networks"
  application_name     = var.application_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = data.aws_availability_zones.available.names #local.availability_zones
  namespace_name       = "${var.application_name}.${terraform.workspace}"
}

module "storage" {
  source                = "./modules/storage"
  application_name      = var.application_name
  uploads_bucket_prefix = "${random_id.random_id_prefix.hex}-assets"
}

module "database" {
  source = "./modules/database"

  application_name                    = var.application_name
  random_id_prefix                    = random_id.random_id_prefix.hex
  global_cluster_identifier           = "${var.application_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
  cluster_identifier                  = "${var.application_name}-${terraform.workspace}-${random_id.random_id_prefix.hex}"
  replication_source_identifier       = var.replication_source_identifier
  source_region                       = var.region
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  database_name                       = var.database_name
  master_username                     = var.master_username
  vpc_security_group_ids              = module.networks.default_sg_id
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  subnet_ids                          = ["${module.networks.private_subnets_id}"]
  final_snapshot_identifier           = "${terraform.workspace}-snapshot-${random_id.random_id_prefix.dec}"
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = var.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  deletion_protection                 = var.deletion_protection
  auto_pause                          = var.auto_pause
  max_capacity                        = var.max_capacity
  min_capacity                        = var.min_capacity
  seconds_until_auto_pause            = var.seconds_until_auto_pause
  api_server_sg                       = module.api.api_ecs_security_group_id
  auth_server_sg                      = module.auth.auth_ecs_security_group_id
  bastion_server_sg                   = module.bastion.bastion_host_security_group
  vpc_id                              = module.networks.vpc_id
}

module "api" {
  source = "./modules/api-service"

  region                  = var.region
  application_name        = var.application_name
  random_id_prefix        = random_id.random_id_prefix.hex
  network                 = module.networks
  database                = module.database
  ecr_api_repository_name = var.ecr_api_repository_name
  scan_on_push            = var.scan_on_push
  api_container_memory    = var.api_container_memory
  api_container_port      = var.api_container_port
  root_domain             = var.root_domain
  buildproject_name       = var.buildproject_name
  api_pipeline_name       = var.api_pipeline_name
  auth_endpoint           = module.auth.auth_endpoint
  ssm_parameters          = module.ssm-parameter
  s3_bucket_id            = module.storage.assets_bucket_id
}

module "auth" {
  source = "./modules/auth-service"

  region                   = var.region
  application_name         = var.application_name
  random_id_prefix         = random_id.random_id_prefix.hex
  ecr_auth_repository_name = var.ecr_auth_repository_name
  network                  = module.networks
  certificate              = module.api.certificate
  auth_container_port      = 3567
  root_domain              = var.root_domain
  api_cluster_depends_on   = module.api
  ecs_cluster              = module.api.ecs_cluster
}

// https://github.com/Guimove/terraform-aws-bastion
module "bastion" {
  source = "./modules/bastion"

  bucket_name                = "bastion-log-${terraform.workspace}-mystack"
  region                     = var.region
  vpc_id                     = module.networks.vpc_id
  is_lb_private              = false
  bastion_host_key_pair      = "bastion"
  create_dns_record          = true
  hosted_zone_id             = module.api.route53_staged_zone.id
  bastion_record_name        = "bastion.${module.api.route53_staged_zone.name}"
  bastion_iam_policy_name    = "bastion-policy-${terraform.workspace}"
  elb_subnets                = [module.networks.public_subnet_1, module.networks.public_subnet_2]
  auto_scaling_group_subnets = [module.networks.private_subnet_1, module.networks.private_subnet_2]
  bucket_force_destroy       = true
  tags = {
    "Name"        = "bastion-${var.application_name}-${terraform.workspace}",
    "description" = "Terraform Bastion server ${var.application_name}-${terraform.workspace}"
  }
}

module "client-webapp" {
  source = "./modules/client-webapp"

  application_name   = var.application_name
  repository_name    = "mystack-platform/mystack-platform-frontend-customer"
  deploy_branch_name = "deploy/${terraform.workspace}"
  base_domain        = "mystack.io"
  app_cname          = "app"
  api_endpoint       = module.api.api_endpoint
  ssm_parameters     = module.ssm-parameter
  s3_bucket_id       = module.storage.assets_bucket_id
}

module "iam-user" {
  source = "./modules/iam-user"

  application_name  = var.application_name
  assets_bucket_arn = module.storage.assets_bucket_arn
}
