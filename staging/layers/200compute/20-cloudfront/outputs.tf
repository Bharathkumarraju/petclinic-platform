output "cloudfront_domain_names" {
  description = "Map of CloudFront distribution domain names, keyed by distribution name"
  value       = { for k, v in module.cloudfront_cdn : k => v.cloudfront_domain_name }
}

output "cloudfront_distribution_ids" {
  description = "Map of CloudFront distribution IDs, keyed by distribution name"
  value       = { for k, v in module.cloudfront_cdn : k => v.cloudfront_distribution_id }
}

output "cloudfront_distribution_arns" {
  description = "Map of CloudFront distribution ARNs, keyed by distribution name"
  value       = { for k, v in module.cloudfront_cdn : k => v.cloudfront_distribution_arn }
}

output "cloudfront_hosted_zone_ids" {
  description = "Map of CloudFront hosted zone IDs, keyed by distribution name"
  value       = { for k, v in module.cloudfront_cdn : k => v.cloudfront_hosted_zone_id }
}