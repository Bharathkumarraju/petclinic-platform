module "opentelemetry_secret_store" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/secret-store"

  namespace   = "opentelemetry"
  environment = local.env

  secret_arns = [module.opentelemetry_secret.secret_arn]
}


module "opentelemetry_secret" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/secrets-manager"

  app_name    = "collector"
  project     = "opentelemetry"
  aws_service = "eks"
  environment = local.env
}
