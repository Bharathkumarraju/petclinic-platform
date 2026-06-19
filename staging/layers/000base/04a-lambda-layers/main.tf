# Shared Lambda Layers
# This module creates centralized Lambda layers that can be referenced by all Lambda functions
module "opentelemetry_layer" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//lambda-layer"

  description = "Shared OpenTelemetry Layer for all lambda functions (Replaces AWS XRay)"
  runtimes    = ["python3.13"]
  layer_name  = "shared-opentelemetry-layer-${local.env}"

  // S3 Related Inputs
  lambda_layer_s3_bucket = "abex-lambda-bucket-network-sin"
  layer_folder           = "opentelemetry"
  layer_version          = "latest"
}
