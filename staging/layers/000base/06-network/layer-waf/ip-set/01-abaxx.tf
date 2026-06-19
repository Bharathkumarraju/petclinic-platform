resource "aws_wafv2_ip_set" "abaxx_wifi" {
  name               = "abaxx_wifi"
  description        = "Int - Abaxx WIFI"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["118.189.14.114/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "abaxx_tech_us_openvpn" {
  name               = "abaxx_tech_us_openvpn"
  description        = "Int - Abaxx Tech US OpenVPN"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["44.214.202.98/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "abaxx_app_middleware_proxy_public" {
  name               = "abaxx_app_middleware_proxy_public"
  description        = "Int - Abaxx Application Middleware/Proxy Public IP"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["34.239.24.131/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "verifier_staging" {
  name               = "verifier_staging"
  description        = "Int - Abaxx Verifier IP Staging"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["54.158.115.35/32", "34.206.120.1/32", "3.224.149.129/32", "52.23.179.55/32", "52.0.24.187/32", "184.73.162.233/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "abaxx_exchange_nat_gw_prod" {
  name               = "abaxx_exchange_nat_gw_prod"
  description        = "Int - Abaxx Exchange NAT GW aws-prod"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["52.76.170.15/32"]
  provider         = aws.vir
}
resource "aws_wafv2_ip_set" "abaxx_exchange_nat_gw_uat" {
  name               = "abaxx_exchange_nat_gw_uat"
  description        = "Int - Abaxx Exchange NAT GW aws-uat"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["13.229.196.208/32"]
  provider         = aws.vir
}
resource "aws_wafv2_ip_set" "abaxx_exchange_nat_gw_staging" {
  name               = "abaxx_exchange_nat_gw_staging"
  description        = "Int - Abaxx Exchange NAT GW aws-staging"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["18.142.16.129/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "abaxx_exchange_nat_gw_external" {
  name               = "abaxx_exchange_nat_gw_external"
  description        = "Int - Abaxx Exchange NAT GW aws-external"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["13.251.91.13/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "elastic" {
  name               = "elastic"
  description        = "Ext - Elastic Synthetics Monitoring"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["34.146.242.49/32","35.243.74.198/32","34.146.210.219/32","34.84.206.230/32","35.194.100.221/32","35.200.141.164/32","34.93.213.243/32","35.200.248.68/32","34.100.138.93/32","34.93.69.134/32","35.247.128.231/32","35.198.204.189/32","34.143.136.8/32","34.143.178.47/32","34.87.175.238/32","35.244.92.47/32","34.116.127.39/32","34.151.94.125/32","35.189.23.110/32","34.151.113.108/32","34.89.88.187/32","34.142.56.159/32","35.230.149.103/32","34.105.205.105/32","34.142.77.240/32","34.107.92.197/32","34.89.161.70/32","34.89.130.80/32","35.246.133.190/32","34.159.84.179/32","35.203.117.124/32","34.152.7.139/32","34.118.150.218/32","34.118.139.162/32","34.152.38.64/32","34.95.230.162/32","34.95.216.92/32","34.95.156.33/32","35.247.254.245/32","34.95.144.204/32","34.86.203.82/32","34.150.229.154/32","34.145.243.197/32","34.85.213.179/32","34.86.147.142/32","34.82.57.5/32","35.197.28.93/32","34.168.61.34/32","34.105.3.10/32","35.247.34.100/32"]
  provider         = aws.vir
}

resource "aws_wafv2_ip_set" "openvpn" {
  name               = "openvpn"
  description        = "Ext - OpenVPN IP Set"
  scope              = "CLOUDFRONT"
    ip_address_version = "IPV4"
    addresses          = ["47.131.72.188/32"]
  provider         = aws.vir
}