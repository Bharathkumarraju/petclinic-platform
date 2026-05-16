output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Route 53 hosted zone name servers for delegation"
  value       = data.aws_route53_zone.this.name_servers
}

output "certificate_arn" {
  description = "ACM wildcard certificate ARN (validated)"
  value       = aws_acm_certificate_validation.wildcard.certificate_arn
}
