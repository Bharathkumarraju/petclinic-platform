# Used on NW-DEV MQ NLB with TLS listener
resource "aws_route53_record" "mq_acm_validation" {
  zone_id = aws_route53_zone.staging_abaxx_exchange.zone_id
  name    = "_23bbd47d1d70812c0a9533dd35f3a673.staging.abaxx.exchange"
  type    = "CNAME"
  ttl     = 300
  records = ["_e24b50a2c2b6d2bee94ad3bd93f2cca1.jkddzztszm.acm-validations.aws."]

  allow_overwrite = true
}