locals {
  container_name = "${var.random_id_prefix}-${var.application_name}-${terraform.workspace}-auth"
}

module "auth-alb" {
  source = "./auth-alb"

  region              = var.region
  application_name    = var.application_name
  random_id_prefix    = var.random_id_prefix
  vpc_id              = var.network.vpc_id
  public_subnet_ids   = ["${var.network.public_subnets_id}"]
  private_subnet_ids  = ["${var.network.private_subnets_id}"]
  security_groups_ids = var.network.security_groups_ids
  ecs_security_group  = module.auth-sg.ecs_security_group
  alb_security_group  = module.auth-sg.alb_security_group
  root_domain         = var.root_domain
  container_port      = var.auth_container_port
  certificate         = var.certificate
}

module "auth-sg" {
  source = "./auth-sg"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = var.random_id_prefix
  vpc_id           = var.network.vpc_id
  container_port   = var.auth_container_port
}

module "auth-iam" {
  source = "./auth-iam"

  application_name = var.application_name
  region           = var.region
  random_id_prefix = var.random_id_prefix
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster.name
  depends_on = [
    var.api_cluster_depends_on
  ]
}

resource "aws_cloudwatch_log_group" "auth_log" {
  name              = "${var.random_id_prefix}-${var.application_name}-auth-${terraform.workspace}"
  retention_in_days = 30

  tags = {
    Environment = "${terraform.workspace}"
    Application = "${var.application_name}-auth"
  }
}

resource "aws_cloudwatch_log_stream" "auth_log_stream" {
  name           = "${var.random_id_prefix}-${terraform.workspace}-auth-jobs-log-stream"
  log_group_name = aws_cloudwatch_log_group.auth_log.name
}

resource "aws_ecs_task_definition" "supertokens" {
  family                   = local.container_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${local.container_name}",
      "image": "registry.supertokens.io/supertokens/supertokens-postgresql",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3567,
          "hostPort": 3567
        }
      ],
      "memory": 512,
      "cpu": 256,
      "secrets": [
        {
          "name": "API_KEYS",
          "valueFrom": "/${var.application_name}/${terraform.workspace}/API_SECRET"
        },
        {
          "name": "POSTGRESQL_CONNECTION_URI",
          "valueFrom": "/${var.application_name}/${terraform.workspace}/POSTGRESQL_CONNECTION_URI"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.auth_log.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = module.auth-iam.ecs_execution_role.arn
  task_role_arn            = module.auth-iam.ecs_execution_role.arn
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${var.random_id_prefix}-auth-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_ecs_service" "auth" {
  name                   = local.container_name
  task_definition        = "${aws_ecs_task_definition.supertokens.family}:${max("${aws_ecs_task_definition.supertokens.revision}", "${aws_ecs_task_definition.supertokens.revision}")}"
  desired_count          = 1
  launch_type            = "FARGATE"
  cluster                = data.aws_ecs_cluster.cluster.id
  enable_execute_command = true

  network_configuration {
    security_groups  = flatten(["${var.network.security_groups_ids}", "${module.auth-sg.ecs_security_group.id}"])
    subnets          = flatten(["${var.network.private_subnets_id}"])
    assign_public_ip = true
  }

  propagate_tags          = "TASK_DEFINITION"
  enable_ecs_managed_tags = true

  health_check_grace_period_seconds = 30

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = module.auth-alb.aws_target_group.arn
    container_name   = local.container_name
    container_port   = var.auth_container_port
  }

  tags = {
    Environment = "${terraform.workspace}"
  }

  # 매번 ECS service가 교체되는 이슈 https://github.com/hashicorp/terraform-provider-aws/issues/11526
  lifecycle {
    ignore_changes = [
      cluster,
      iam_role,
      id,
      platform_version
    ]
  }
}
