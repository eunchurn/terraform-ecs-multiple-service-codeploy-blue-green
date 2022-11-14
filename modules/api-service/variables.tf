variable "region" {
  description = "AWS region..."
}

variable "application_name" {
  description = "Application name"
}

variable "network" {
  description = "VPC Network"
}

variable "database" {
  description = "AWS RDS Aurora Database"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "ecr_api_repository_name" {
  description = "The name of API repository"
  type        = string
  default     = "mystack-api"
}

variable "scan_on_push" {
  description = "ECR scan on push"
  type        = bool
  default     = true
}

variable "api_container_memory" {
  description = "API container memory"
  type        = number
  default     = 512
}

variable "api_container_port" {
  description = "API container port"
  type        = number
  default     = 8000
}

variable "root_domain" {
  description = "Root domain of this application (API)"
  type        = string
  default     = "platform.mystack.io"
}


## CodeBuild
variable "buildproject_name" {
  description = "Build project name"
  type        = string
  default     = "mystack-api"
}

## API: CodePipeline
variable "api_pipeline_name" {
  description = "Code pipeline project name"
  type        = string
  default     = "mystack-api-pipeline"
}
variable "auth_endpoint" {
  description = "Auth Endpoint"
}
variable "ssm_parameters" {
  description = "AWS SSM Module"
}

variable "s3_bucket_id" {
  description = "AWS S3 Bucket ID"
}
