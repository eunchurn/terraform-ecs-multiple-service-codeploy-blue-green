resource "aws_codebuild_project" "frontend_build_project" {
  name          = "${var.application_name}_frontend_${var.environment}"
  description   = "codebuild stage"
  service_role  = aws_iam_role.codebuild_frontend.arn
  build_timeout = var.build_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${var.codebuild_bucket_name}-${var.environment}/_cache/archives"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./buildspec.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ENV"
      value = var.environment
    }

    environment_variable {
      name  = "S3_BUCKET_DESTINATION"
      value = var.s3_bucket_destination
    }
    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = var.cloudfront_distrubution_id
    }
    environment_variable {
      name  = "APOLLO_KEY"
      value = var.ssm_parameters.APOLLO_KEY
    }
    environment_variable {
      name  = "REACT_APP_API_URL"
      value = "https://${var.api_endpoint}"
    }
    environment_variable {
      name  = "REACT_APP_HOST_URL"
      value = "https://${var.website_endpoint}"
    }
    environment_variable {
      name  = "REACT_APP_KAKAO_KEY"
      value = var.ssm_parameters.KAKAO_KEY
    }

    environment_variable {
      name  = "REACT_APP_S3_BUCKET_ID"
      value = var.client_s3_bucket_id
    }
  }

  tags = {
    Name        = "${var.application_name}-frontend-codebuild-${var.environment}"
    Environment = var.environment
  }
}
