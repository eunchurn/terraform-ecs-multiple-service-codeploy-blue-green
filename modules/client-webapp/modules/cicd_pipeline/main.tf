# Frontend Pipeline
module "frontend_pipeline" {
  source                     = "./frontend_pipeline"
  application_name           = var.application_name
  s3_bucket_destination      = "${var.application_name}-${var.environment}"
  pipeline_bucket_name       = "${var.application_name}-codepipeline"
  codebuild_bucket_name      = "${var.application_name}-codebuild"
  repository_name            = var.repository_name
  branch_name                = var.branch_name
  environment                = var.environment
  cloudfront_distrubution_id = var.cloudfront_distrubution_id
  ssm_parameters             = var.ssm_parameters
  api_endpoint               = var.api_endpoint
  website_endpoint           = var.website_endpoint
  client_s3_bucket_id        = var.s3_bucket_id
}
