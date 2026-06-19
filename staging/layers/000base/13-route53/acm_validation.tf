# ACM Certificate Validation Records
# These records validate ACM certificates for staging.abaxx.exchange

locals {
  # Extract ACM validation records for staging.abaxx.exchange domain
  acm_validation_records = merge(
    # ACM certificates from us-east-1 (for CloudFront)
    {
      for dvo in try(data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_us_east_1, []) :
      "${dvo.domain_name}-${dvo.resource_record_name}-us-east-1" => {
        name   = dvo.resource_record_name
        type   = dvo.resource_record_type
        record = dvo.resource_record_value
      }
      if length(regexall("staging\\.abaxx\\.exchange", dvo.domain_name)) > 0
    },
    # ACM certificates from ap-southeast-1 (for regional resources)
    {
      for dvo in try(data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_ap_southeast_1, []) :
      "${dvo.domain_name}-${dvo.resource_record_name}-ap-southeast-1" => {
        name   = dvo.resource_record_name
        type   = dvo.resource_record_type
        record = dvo.resource_record_value
      }
      if length(regexall("staging\\.abaxx\\.exchange", dvo.domain_name)) > 0
    }
  )

  # Deduplicate validation records (same CNAME for both regions)
  acm_validation_records_unique = {
    for k, v in local.acm_validation_records : v.name => v...
  }
}

# Create ACM validation records in Route53
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for name, records in local.acm_validation_records_unique : name => records[0]
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]

  allow_overwrite = true
}
