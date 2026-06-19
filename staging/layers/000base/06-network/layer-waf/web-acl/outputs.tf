output "clearing_staging_cloudfront_cdn_web_acl_arn" {
  description = "Clearing Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.clearing_staging_cloudfront_cdn_web_acl.arn
}

output "clearing_backend_staging_cloudfront_cdn_web_acl_arn" {
  description = "Clearing_backend Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.clearing_backend_staging_cloudfront_cdn_web_acl.arn
}

output "api_staging_cloudfront_cdn_web_acl_arn" {
  description = "API Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.api_staging_cloudfront_cdn_web_acl.arn
}

output "api_abaxxtech_staging_cloudfront_cdn_web_acl_arn" {
  description = "API AbaxxTech Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.api_abaxxtech_staging_cloudfront_cdn_web_acl.arn
}

output "atrp_backend_staging_cloudfront_cdn_web_acl_arn" {
  description = "ATRP Backend Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.atrp_backend_staging_cloudfront_cdn_web_acl.arn
}

output "auth_clearing_staging_cloudfront_cdn_web_acl_arn" {
  description = "Auth Clearing Staging CloudFront WAFv2 Web ACL arn"
  value       = aws_wafv2_web_acl.auth_clearing_staging_cloudfront_cdn_web_acl.arn
}