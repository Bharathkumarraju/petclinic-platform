output "staging_xabx_net_acm_us_east_1" {
  value = module.staging_xabx_net_acm_us_east_1.acm_certificate_domain_validation_options
}
output "staging_xabx_net_acm_ap_southeast_1" {
  value = module.staging_xabx_net_acm_ap_southeast_1.acm_certificate_domain_validation_options
}

output "staging_abaxx_exchange_acm_us_east_1" {
  value = module.staging_abaxx_exchange_acm_us_east_1.acm_certificate_domain_validation_options
}

output "staging_abaxx_exchange_acm_us_east_1_arn" {
  value = module.staging_abaxx_exchange_acm_us_east_1.acm_certificate_arn
}

output "staging_abaxx_exchange_acm_ap_southeast_1" {
  value = module.staging_abaxx_exchange_acm_ap_southeast_1.acm_certificate_domain_validation_options
}

output "staging_abaxx_exchange_acm_ap_southeast_1_arn" {
  value = module.staging_abaxx_exchange_acm_ap_southeast_1.acm_certificate_arn
}