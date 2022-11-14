variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "Applicaiton environment"
  type        = string
}

variable "certificate_domain_name1" {
  description = "Domain name of certificate .io"
  type        = string
}

variable "cloudfront_domain_name1" {
  description = "CloudFront domain name .io"
  type        = string
}
