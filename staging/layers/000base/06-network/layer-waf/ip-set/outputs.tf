output "abaxx_wifi_arn" {
  description = "ARN of the Abaxx WIFI IP set"
  value       = aws_wafv2_ip_set.abaxx_wifi.arn
}

output "abaxx_tech_us_openvpn_arn" {
  description = "ARN of the Tech US OpenVPN IP set"
  value       = aws_wafv2_ip_set.abaxx_tech_us_openvpn.arn
}

output "abaxx_app_middleware_proxy_public_arn" {
  description = "ARN of the Application Middleware/Proxy Public IP set"
  value       = aws_wafv2_ip_set.abaxx_app_middleware_proxy_public.arn
}

output "verifier_staging_arn" {
  description = "ARN of the Verifier Staging IP set"
  value       = aws_wafv2_ip_set.verifier_staging.arn
}

output "abaxx_exchange_nat_gw_prod_arn" {
  description = "ARN of the Exchange NAT Gateway PROD IP set"
  value       = aws_wafv2_ip_set.abaxx_exchange_nat_gw_prod.arn
}

output "abaxx_exchange_nat_gw_uat_arn" {
  description = "ARN of the Exchange NAT Gateway UAT IP set"
  value       = aws_wafv2_ip_set.abaxx_exchange_nat_gw_uat.arn
}

output "abaxx_exchange_nat_gw_staging_arn" {
  description = "ARN of the Exchange NAT Gateway Staging IP set"
  value       = aws_wafv2_ip_set.abaxx_exchange_nat_gw_staging.arn
}

output "abaxx_exchange_nat_gw_external_arn" {
  description = "ARN of the Exchange NAT Gateway External IP set"
  value       = aws_wafv2_ip_set.abaxx_exchange_nat_gw_external.arn
}

output "elastic_arn" {
  description = "ARN of the Elastic Synthetics Monitoring IP set"
  value       = aws_wafv2_ip_set.elastic.arn
}

output "baymarkets_arn" {
  description = "ARN of the Baymarkets Vendor IP set"
  value       = aws_wafv2_ip_set.baymarkets.arn
}

output "openvpn_arn" {
  description = "ARN of the OpenVPN IP set"
  value       = aws_wafv2_ip_set.openvpn.arn
}