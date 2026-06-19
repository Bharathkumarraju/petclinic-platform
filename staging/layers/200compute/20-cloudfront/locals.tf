locals {
  cloudfront_distributions = {
    clearing_staging = {
      cloudfront_name        = "abex-cloudfront-clearing-${local.env}-xabx-net"
      cloudfront_description = "Cloudfront Distribution for clearing.${local.env}.xabx.net"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com"
      origin_name            = "clearing.staging.xabx.net"
      acm_certificate_arn    = "arn:aws:acm:us-east-1:993533333148:certificate/869c732d-5e77-4106-9f39-fc2fce13ab5c"
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.clearing_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["clearing.staging.xabx.net"]
    }
    clearing = {
      cloudfront_name        = "abex-clearing-${local.env}-abaxx-exchange"
      cloudfront_description = "Cloudfront Distribution for clearing.${local.env}.abaxx.exchange"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "clearing.staging.abaxx.exchange"
      acm_certificate_arn    = data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_us_east_1_arn
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.clearing_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["clearing.staging.abaxx.exchange"]
    }
    clearing_backend = {
      cloudfront_name        = "abex-clearing-backend-${local.env}-abaxx-exchange"
      cloudfront_description = "Cloudfront Distribution for clearing-backend.${local.env}.abaxx.exchange"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "clearing-backend.staging.abaxx.exchange"
      acm_certificate_arn    = data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_us_east_1_arn
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.clearing_backend_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["clearing-backend.staging.abaxx.exchange"]
    }
    api = {
      cloudfront_name        = "abex-api-${local.env}-xabx-net"
      cloudfront_description = "Cloudfront Distribution for api.${local.env}.xabx.net"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "api.staging.xabx.net"
      acm_certificate_arn    = "arn:aws:acm:us-east-1:993533333148:certificate/869c732d-5e77-4106-9f39-fc2fce13ab5c"
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.api_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["api.staging.xabx.net"]
    }
    api_abaxxtech = {
      cloudfront_name        = "abex-api-abaxxtech-${local.env}-xabx-net"
      cloudfront_description = "Cloudfront Distribution for api-abaxxtech.${local.env}.xabx.net"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "api-abaxxtech.staging.xabx.net"
      acm_certificate_arn    = "arn:aws:acm:us-east-1:993533333148:certificate/869c732d-5e77-4106-9f39-fc2fce13ab5c"
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.api_abaxxtech_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["api-abaxxtech.staging.xabx.net"]
    }
    atrp_backend = {
      cloudfront_name        = "abex-atrp-backend-${local.env}-xabx-net"
      cloudfront_description = "Cloudfront Distribution for atrp-backend.${local.env}.xabx.net"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "atrp-backend.staging.xabx.net"
      acm_certificate_arn    = "arn:aws:acm:us-east-1:993533333148:certificate/869c732d-5e77-4106-9f39-fc2fce13ab5c"
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.atrp_backend_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["atrp-backend.staging.xabx.net"]
    }
    auth_clearing = {
      cloudfront_name        = "abex-auth-clearing-${local.env}-xabx-net"
      cloudfront_description = "Cloudfront Distribution for auth.clearing.${local.env}.xabx.net"
      origin_fqdn            = "internal-k8s-cdn01-314aa6a1c5-348829312.ap-southeast-1.elb.amazonaws.com" # Created by helm, cant reference data block
      origin_name            = "auth.clearing.staging.xabx.net"
      acm_certificate_arn    = "arn:aws:acm:us-east-1:993533333148:certificate/869c732d-5e77-4106-9f39-fc2fce13ab5c"
      logging_bucket         = data.terraform_remote_state.bucket.outputs.cloudfront_logs_bucket_sin_name
      web_acl_arn            = data.terraform_remote_state.web-acl.outputs.auth_clearing_staging_cloudfront_cdn_web_acl_arn
      alternate_domains      = ["auth.clearing.staging.xabx.net"]
    }
  }
}
