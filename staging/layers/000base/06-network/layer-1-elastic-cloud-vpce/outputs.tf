output "elastic-cloud-endpoint" {
  description = "Endpoint for elastic-cloud-endpoint"
  value       = aws_vpc_endpoint.elastic-cloud-endpoint.id
}
