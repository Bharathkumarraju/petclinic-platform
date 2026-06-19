# Route53 Public Hosted Zone for staging.abaxx.exchange
resource "aws_route53_zone" "staging_abaxx_exchange" {
  name    = "staging.abaxx.exchange"
  comment = "Public hosted zone for staging environment"

  tags = {
    Environment  = local.env
    Name         = "staging.abaxx.exchange"
    ManagedBy    = "Terraform"
    map-migrated = "mig46499"
  }
}
