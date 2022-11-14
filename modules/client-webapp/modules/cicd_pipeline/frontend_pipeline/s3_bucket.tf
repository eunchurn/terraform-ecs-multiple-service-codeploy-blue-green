# S3 bucket used by CodePipeline for artifacts
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.pipeline_bucket_name}-${var.environment}"

  tags = {
    Name = "${var.pipeline_bucket_name}-${var.environment}"
  }
}

resource "aws_s3_bucket_acl" "pipeline_bucket_acl" {
  bucket = aws_s3_bucket.pipeline_bucket.id
  acl    = var.bucket_acl
}


# S3 bucket used by CodeBuild for cache
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.codebuild_bucket_name}-${var.environment}"

  tags = {
    Name = "${var.codebuild_bucket_name}-${var.environment}"
  }
}

resource "aws_s3_bucket_acl" "codebuild_bucket_acl" {
  bucket = aws_s3_bucket.codebuild_bucket.id
  acl    = var.bucket_acl
}
