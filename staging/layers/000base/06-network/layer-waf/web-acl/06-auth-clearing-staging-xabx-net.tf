##########################################
# auth.clearing.staging.xabx.net 
##########################################

resource "aws_wafv2_web_acl" "auth_clearing_staging_cloudfront_cdn_web_acl" {
  name        = "auth_clearing_staging_cloudfront_cdn_web_acl"
  scope       = "CLOUDFRONT"
  description = "Web ACL to be attached to auth-clearing Staging CloudFront CDN"

  default_action {
    block {} # Blocks everything by default
  }

  rule {
    name     = "AllowAbaxxWiFi"
    priority = 1
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_wifi_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxWiFi"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxTechUSOpenVPN"
    priority = 2
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_tech_us_openvpn_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxTechUSOpenVPN"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxAppMiddlewareProxyPublic"
    priority = 3
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_app_middleware_proxy_public_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxAppMiddlewareProxyPublic"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxExchangeNATGWProd"
    priority = 4
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_exchange_nat_gw_prod_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxExchangeNATGWProd"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxExchangeNATGWUat"
    priority = 5
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_exchange_nat_gw_uat_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxExchangeNATGWUat"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxExchangeNATGWStaging"
    priority = 6
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.abaxx_exchange_nat_gw_staging_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxExchangeNATGWStaging"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowAbaxxExchangeOpenVPN"
    priority = 7
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.openvpn_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAbaxxExchangeOpenVPN"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowElasticSyntheticsMonitoring"
    priority = 8
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.elastic_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowElasticSyntheticsMonitoring"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AllowBaymarkets"
    priority = 9
    action {
      allow {} # Allows if the IP matches the set
    }
    statement {
      ip_set_reference_statement {
        arn = data.terraform_remote_state.ip-set.outputs.baymarkets_arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowBaymarkets"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "auth_clearing_staging_cloudfront_cdn_web_acl"
    sampled_requests_enabled   = true
  }

  provider = aws.vir
}