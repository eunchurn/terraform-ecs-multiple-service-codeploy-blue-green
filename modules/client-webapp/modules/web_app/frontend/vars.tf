variable "bucket_name" {
  type        = string
  description = "S3 bucket storing static files for website"
}

variable "bucket_acl" {
  type        = string
  default     = "private"
  description = "Bucket ACL (Access Control Listing)"
}

variable "versioning" {
  type        = string
  default     = "Enabled"
  description = "Flag to determine whether bucket versioning is enabled or not"
}

variable "environment" {
  type        = string
  description = "Application enviroment"
}

variable "certificate_domain_name1" {
  description = "Domain name of certificate .io"
  type        = string
}

variable "cloudfront_domain_name1" {
  description = "CloudFront domain name .io"
  type        = string
}
