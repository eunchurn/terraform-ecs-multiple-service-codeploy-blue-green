variable "region" {
  description = "AWS Region"
}

variable "application_name" {
  description = "Application name"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "network" {
  description = "VPC Network"
}

variable "ecr_auth_repository_name" {
  description = "The name of the repisitory"
}

variable "certificate" {
  description = "ACM Certificate"
}

variable "auth_container_port" {
  description = "Auth Container Port"
}

variable "root_domain" {
  description = "Root domain of this application (Auth)"
  type        = string
  default     = "platform.mystack.io"
}

variable "api_cluster_depends_on" {
  description = "API Cluster"
}

variable "ecs_cluster" {
  description = "ECS Cluster"
}
