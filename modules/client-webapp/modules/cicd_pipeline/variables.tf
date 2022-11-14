variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "Applicaiton environment"
  type        = string
}

variable "repository_name" {
  description = "Github Repository full name"
  type        = string
  default     = "mystack-platform/mystack-demo"
}

variable "branch_name" {
  type = string
}

variable "cloudfront_distrubution_id" {
  description = "AWS CloudFront Distribution name"
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
  description = "AWS SSM Parameters"
}

variable "s3_bucket_id" {
  description = "AWS S3 Bucket ID"
}
