output "opentelemetry_layer_arn" {
  description = "ARN of the shared OpenTelemetry layer for Lambda functions"
  value       = module.opentelemetry_layer.layer_arn
}

output "opentelemetry_layer_version" {
  description = "Version of the shared OpenTelemetry layer"
  value       = module.opentelemetry_layer.layer_version
}
