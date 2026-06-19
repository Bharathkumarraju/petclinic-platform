# Lambda Layers

This layer creates shared Lambda layers that are used across multiple Lambda functions in the environment.

## Purpose

Creates centralized Lambda layers to avoid duplication and ensure consistency across all Lambda functions.

## Layers Created

### OpenTelemetry Layer
- **Name**: `shared-opentelemetry-layer-{env}`
- **Runtime**: Python 3.13
- **Architecture**: x86_64, arm64
- **Purpose**: Provides OpenTelemetry instrumentation and tracing capabilities

## Outputs

- `opentelemetry_layer_arn` - ARN of the shared OpenTelemetry layer
- `opentelemetry_layer_version` - Version number of the layer

## Usage in Other Layers

Lambda functions in other layers can reference this layer via remote state:

```hcl
data "terraform_remote_state" "lambda_layers" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/lambda-layers"
    region = "ap-southeast-1"
  }
}

module "my_lambda" {
  source = "..."

  shared_opentelemetry_layer_arn = data.terraform_remote_state.lambda_layers.outputs.opentelemetry_layer_arn
}
```

## Deployment Order

This layer should be deployed after:
- 01-kms
- 02-cloudwatch
- 03-bucket
- 04-iam-services

And before any layers containing Lambda functions:
- 05-sns
- 07-cloudwatch-to-s3
- 10-cloudwatch-to-firehose
