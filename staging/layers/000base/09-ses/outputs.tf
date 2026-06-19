output "ses_config_set" {
  value = resource.aws_ses_configuration_set.ses_config_set
}

output "ses_logs_kinesis_fh" {
  value = resource.aws_kinesis_firehose_delivery_stream.ses_logs_kinesis_fh
}

output "ses_logs_event" {
  value = resource.aws_ses_event_destination.ses_logs_event
}

# SES Domain Identity Outputs for DNS verification
output "ses_domain_identities" {
  description = "SES domain identities and their verification tokens"
  value = {
    for domain, identity in aws_ses_domain_identity.domain : domain => {
      domain             = identity.domain
      arn                = identity.arn
      verification_token = identity.verification_token
    }
  }
}

# SES DKIM Outputs for email authentication
output "ses_domain_dkim_tokens" {
  description = "SES DKIM tokens for DNS CNAME records"
  value = {
    for domain, dkim in aws_ses_domain_dkim.domain : domain => {
      domain       = dkim.domain
      dkim_tokens  = dkim.dkim_tokens
    }
  }
}

# Formatted DNS records for easy consumption
output "ses_dns_records" {
  description = "All DNS records needed for SES domain verification and DKIM"
  value = {
    for domain in local.ses_domains : domain => {
      # Domain verification TXT record
      verification_record = {
        type  = "TXT"
        name  = "_amazonses.${domain}"
        value = aws_ses_domain_identity.domain[domain].verification_token
      }
      # DKIM CNAME records (3 records)
      dkim_records = [
        for token in aws_ses_domain_dkim.domain[domain].dkim_tokens : {
          type  = "CNAME"
          name  = "${token}._domainkey.${domain}"
          value = "${token}.dkim.amazonses.com"
        }
      ]
      # DMARC TXT record
      dmarc_record = {
        type  = "TXT"
        name  = "_dmarc.${domain}"
        value = "v=DMARC1; p=none; rua=mailto:trm@abaxx.exchange"
      }
      # Custom MAIL FROM DNS records (MX + SPF TXT on ses.<domain>)
      mail_from_records = {
        mx = {
          type     = "MX"
          name     = "ses.${domain}"
          value    = "10 feedback-smtp.ap-southeast-1.amazonses.com"
          priority = 10
        }
        spf = {
          type  = "TXT"
          name  = "ses.${domain}"
          value = "v=spf1 include:amazonses.com ~all"
        }
      }
    }
  }
}