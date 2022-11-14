data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.website_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.this.iam_arn}"]
    }
  }
}
