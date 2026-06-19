# SES Domain Verification Records
# These records verify domain ownership for SES

# SES Domain Verification TXT Record
# Creates records for all domains ending with .staging.abaxx.exchange
resource "aws_route53_record" "ses_verification" {
  for_each = {
    for domain, identity in try(data.terraform_remote_state.ses.outputs.ses_domain_identities, {}) :
    domain => identity
    if length(regexall("staging\\.abaxx\\.exchange$", domain)) > 0
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "_amazonses.${each.value.domain}"
  type    = "TXT"
  ttl     = 300
  records = [each.value.verification_token]
}

# SES DKIM CNAME Records (3 records per domain)
# These records enable DKIM email authentication
locals {
  ses_dkim_records = flatten([
    for domain, dkim_data in try(data.terraform_remote_state.ses.outputs.ses_domain_dkim_tokens, {}) : [
      for idx, token in dkim_data.dkim_tokens : {
        key    = "${domain}-dkim-${idx}"
        domain = domain
        name   = "${token}._domainkey.${domain}"
        value  = "${token}.dkim.amazonses.com"
      }
    ] if length(regexall("staging\\.abaxx\\.exchange$", domain)) > 0
  ])
}

resource "aws_route53_record" "ses_dkim" {
  for_each = {
    for record in local.ses_dkim_records : record.key => record
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 300
  records = [each.value.value]
}

# SES DMARC TXT Records
# These records publish the DMARC policy for each domain
resource "aws_route53_record" "ses_dmarc" {
  for_each = {
    for domain, dns in try(data.terraform_remote_state.ses.outputs.ses_dns_records, {}) :
    domain => dns.dmarc_record
    if length(regexall("staging\\.abaxx\\.exchange$", domain)) > 0
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = each.value.name
  type    = "TXT"
  ttl     = 300
  records = [each.value.value]
}

# SES Custom MAIL FROM - MX Records
# Routes bounce notifications back to SES for each ses.<domain>
resource "aws_route53_record" "ses_mail_from_mx" {
  for_each = {
    for domain, dns in try(data.terraform_remote_state.ses.outputs.ses_dns_records, {}) :
    domain => dns.mail_from_records.mx
    if length(regexall("staging\\.abaxx\\.exchange$", domain)) > 0
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = each.value.name
  type    = "MX"
  ttl     = 300
  records = [each.value.value]
}

# SES Custom MAIL FROM - SPF TXT Records
# Authorises SES to send mail from ses.<domain>
resource "aws_route53_record" "ses_mail_from_spf" {
  for_each = {
    for domain, dns in try(data.terraform_remote_state.ses.outputs.ses_dns_records, {}) :
    domain => dns.mail_from_records.spf
    if length(regexall("staging\\.abaxx\\.exchange$", domain)) > 0
  }

  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = each.value.name
  type    = "TXT"
  ttl     = 300
  records = [each.value.value]
}