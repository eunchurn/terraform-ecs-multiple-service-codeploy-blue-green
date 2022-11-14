variable "application_name" {
  description = "Application name"
}

variable "base_domain" {
  description = "Base domain"
  default     = "mystack.io"
}

variable "app_cname" {
  description = "CNAME of web app"
  default     = "app"
}

variable "repository_name" {
  description = "GitHub Repository name Organization/Respository"
}

variable "deploy_branch_name" {
  description = "Deployment branch name"
}

variable "api_endpoint" {
  description = "API Endpoint for REACT_APP_API_URL"
  type        = string
}

variable "ssm_parameters" {
  description = "AWS SSM Parameters"
}

variable "s3_bucket_id" {
  description = "AWS S3 Bucket ID"
}
