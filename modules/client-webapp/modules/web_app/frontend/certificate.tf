provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_acm_certificate" "certificate" {
  domain = var.certificate_domain_name1

  statuses = ["ISSUED"]
  provider = aws.virginia
}

data "aws_route53_zone" "route53_zone" {
  name = var.certificate_domain_name1
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.cloudfront_domain_name1
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
