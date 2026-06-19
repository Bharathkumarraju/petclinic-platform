# ACM for Cloudfront in us-east-1
module "staging_xabx_net_acm_us_east_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name            = "xabx.net"
  create_route53_records = false

  validation_method = "DNS"

  subject_alternative_names = [
    "*.xabx.net",
    "*.staging.xabx.net",
    "*.clearing.staging.xabx.net",
  ]

  wait_for_validation = false

  tags = {
    Name = "xabx.net"
  }

  region = "us-east-1"
}

# ACM for Cloudfront in ap-southeast-1
module "staging_xabx_net_acm_ap_southeast_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name            = "xabx.net"
  create_route53_records = false

  validation_method = "DNS"

  subject_alternative_names = [
    "*.xabx.net",
    "*.staging.xabx.net",
    "*.clearing.staging.xabx.net",
  ]

  wait_for_validation = false

  tags = {
    Name = "xabx.net"
  }

  region = "ap-southeast-1"
}


# ACM for Cloudfront in us-east-1
module "staging_abaxx_exchange_acm_us_east_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name            = "staging.abaxx.exchange"
  create_route53_records = false

  validation_method = "DNS"

  subject_alternative_names = [
    "*.staging.abaxx.exchange",
  ]

  wait_for_validation = false

  tags = {
    Name = "staging.abaxx.exchange"
  }

  region = "us-east-1"
}

# ACM for Cloudfront in ap-southeast-1
module "staging_abaxx_exchange_acm_ap_southeast_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name            = "staging.abaxx.exchange"
  create_route53_records = false

  validation_method = "DNS"

  subject_alternative_names = [
    "*.staging.abaxx.exchange",
  ]

  wait_for_validation = false

  tags = {
    Name = "staging.abaxx.exchange"
  }

  region = "ap-southeast-1"
}
