resource "aws_route53_record" "mq" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "mq.staging.abaxx.exchange"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.global_accelerator.outputs.mq_staging_accelerator_dns_name
    zone_id                = data.terraform_remote_state.global_accelerator.outputs.mq_staging_accelerator_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}

resource "aws_route53_record" "sftp" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "sftp.staging.abaxx.exchange"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.global_accelerator.outputs.sftp_staging_accelerator_dns_name
    zone_id                = data.terraform_remote_state.global_accelerator.outputs.sftp_staging_accelerator_zone_id
    evaluate_target_health = false
  }

  allow_overwrite = true
}

resource "aws_route53_record" "clearing_ipv4" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "clearing.staging.abaxx.exchange"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.cloudfront.outputs.cloudfront_domain_names["clearing"]
    zone_id                = data.terraform_remote_state.cloudfront.outputs.cloudfront_hosted_zone_ids["clearing"]
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "clearing_ipv6" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "clearing.staging.abaxx.exchange"
  type    = "AAAA"

  alias {
    name                   = data.terraform_remote_state.cloudfront.outputs.cloudfront_domain_names["clearing"]
    zone_id                = data.terraform_remote_state.cloudfront.outputs.cloudfront_hosted_zone_ids["clearing"]
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "clearing_backend_ipv4" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "clearing-backend.staging.abaxx.exchange"
  type    = "A"
  
  alias {
    name                   = data.terraform_remote_state.cloudfront.outputs.cloudfront_domain_names["clearing_backend"]
    zone_id                = data.terraform_remote_state.cloudfront.outputs.cloudfront_hosted_zone_ids["clearing_backend"]
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "clearing_backend_ipv6" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "clearing-backend.staging.abaxx.exchange"
  type    = "AAAA"
  
  alias {
    name                   = data.terraform_remote_state.cloudfront.outputs.cloudfront_domain_names["clearing_backend"]
    zone_id                = data.terraform_remote_state.cloudfront.outputs.cloudfront_hosted_zone_ids["clearing_backend"]
    evaluate_target_health = false
  }
}