resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "React App"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_domain_name
    origin_id   = "website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "website"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  custom_error_response {
    error_caching_min_ttl = 3600
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 3600
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.bucket_name}-distribution"
    Environment = var.environment
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }
  aliases = [var.cloudfront_domain_name1]
}

output "website_cdn_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "website_endpoint" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}
