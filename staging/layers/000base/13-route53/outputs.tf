# Route53 Hosted Zone Outputs
output "staging_abaxx_exchange_zone_id" {
  description = "Route53 hosted zone ID for staging.abaxx.exchange"
  value       = aws_route53_zone.staging_abaxx_exchange.zone_id
}

output "staging_abaxx_exchange_name_servers" {
  description = "Name servers for staging.abaxx.exchange hosted zone - configure these at your parent domain"
  value       = aws_route53_zone.staging_abaxx_exchange.name_servers
}

output "staging_abaxx_exchange_zone" {
  description = "Full Route53 hosted zone object for staging.abaxx.exchange"
  value       = aws_route53_zone.staging_abaxx_exchange
}