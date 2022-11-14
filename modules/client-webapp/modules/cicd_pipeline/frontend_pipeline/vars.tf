variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "build_timeout" {
  type        = string
  default     = "10"
  description = "Build time out duration"
}

variable "repository_name" {
  description = "Name of git repository"
  type        = string
}

variable "branch_name" {
  type = string
}

variable "s3_bucket_destination" {
  type        = string
  description = "S3 bucket destination for the frontend static site"
}

variable "pipeline_bucket_name" {
  type        = string
  default     = "luka-frontend-pipeline-bucket"
  description = "S3 bucket for pipeline artifacts"
}

variable "codebuild_bucket_name" {
  type        = string
  default     = "luka-frontend-codebuild-bucket"
  description = "S3 bucket for build cache"
}

variable "bucket_acl" {
  type        = string
  default     = "private"
  description = "Bucket ACL (Access Control Listing)"
}

variable "environment" {
  description = "Applicaiton environment"
  type        = string
}

variable "codebuild_image" {
  description = "CodeBuild Container base image"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  type        = string
}

variable "cloudfront_distrubution_id" {
  description = "AWS CloudFront Distribution ID"
  type        = string
}

variable "api_endpoint" {
  description = "API Endpoint for REACT_APP_API_URL"
  type        = string
}

variable "website_endpoint" {
  description = "WEB App Endpoint for REACT_APP_HOST_URL"
  type        = string
}

variable "ssm_parameters" {
  description = "AWS SSM Paramters"
}

variable "client_s3_bucket_id" {
  description = "AWS S3 Bucket ID"
}
