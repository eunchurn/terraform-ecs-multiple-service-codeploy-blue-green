locals {
  application_name = "${var.application_name}-curation"
  environment      = terraform.workspace
  domain           = terraform.workspace == "prod" ? "${var.app_cname}.${var.base_domain}" : "${var.app_cname}-${terraform.workspace}.${var.base_domain}"
}

module "web_app" {
  source = "./modules/web_app"

  application_name         = local.application_name
  environment              = local.environment
  certificate_domain_name1 = var.base_domain
  cloudfront_domain_name1  = local.domain
}

module "cicd_pipeline" {
  source = "./modules/cicd_pipeline"

  application_name           = local.application_name
  environment                = local.environment
  repository_name            = var.repository_name    // Github {organization}/{repository_name}
  branch_name                = var.deploy_branch_name // Deployment branch
  cloudfront_distrubution_id = module.web_app.cloudfront_distribution_id
  api_endpoint               = var.api_endpoint
  website_endpoint           = local.domain
  ssm_parameters             = var.ssm_parameters
  s3_bucket_id               = var.s3_bucket_id
}


output "website_cdn_id" {
  value = module.web_app.website_cdn_id
}

output "website_endpoint" {
  value = module.web_app.website_endpoint
}
