resource "aws_wafv2_ip_set" "baymarkets" {
  name               = "baymarkets"
  description        = "Ext - Vendor Baymarkets"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["81.167.216.18/32"]
  provider         = aws.vir
}