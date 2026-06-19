module "cloudfront_cdn" {
  for_each = local.cloudfront_distributions

  providers = {
    aws     = aws
    aws.vir = aws.vir   # pass the us-east-1 alias in
  }

  source                 = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//cloudfront"
  cloudfront_name        = each.value.cloudfront_name
  cloudfront_description = each.value.cloudfront_description
  web_acl_arn            = each.value.web_acl_arn
  origin_fqdn            = each.value.origin_fqdn
  origin_name            = each.value.origin_name
  acm_certificate_arn    = each.value.acm_certificate_arn
  logging_bucket         = each.value.logging_bucket
  env                    = local.env
  alternate_domains      = each.value.alternate_domains
}
