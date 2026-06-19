locals {

  # Log Group Prefix
  cloudwatch_prefix = {
    #Structured to add more kinds of logs for different EKS services
    authn_service_logs     = "/aws/eks/${local.env}/new-pod/authn"
    eprime_service_logs    = "/aws/eks/${local.env}/new-pod/eprime"
    eprime_trace_logs      = "/aws/eks/${local.env}/new/eprime-trace"
    eprime_app_logs        = "/aws/eks/${local.env}/new/eprime"
    exchange_service_logs  = "/aws/eks/${local.env}/new-pod/exchange"
    authx_service_logs     = "/aws/eks/${local.env}/new-pod/authx"
    authxweb_service_logs  = "/aws/eks/${local.env}/new-pod/authx-web"
    clara_service_logs     = "/aws/eks/${local.env}/new-pod/clara"
    claus_service_logs     = "/aws/eks/${local.env}/new-pod/claus"
    clic_service_logs      = "/aws/eks/${local.env}/new-pod/clic"
    cloc_service_logs      = "/aws/eks/${local.env}/new-pod/cloc"
    coco_service_logs      = "/aws/eks/${local.env}/new-pod/coco"
    keycloak_service_logs  = "/aws/eks/${local.env}/new-pod/keycloak"
    tcexberry_service_logs = "/aws/eks/${local.env}/new-pod/tcexberry"
  }

  # Log Group Map
  eks_cloudwatch_log_groups = {
    authn_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["authn_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Authn"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    eprime_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["eprime_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Eprime"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    eprime_trace_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["eprime_trace_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Eprime Trace Logs"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    eprime_app_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["eprime_app_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Eprime App Trace Logs"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    exchange_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["exchange_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Exchange"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    authx_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["authx_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Authx"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    authxweb_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["authxweb_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-authx-web"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    clara_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["clara_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Clara"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    claus_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["claus_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Claus"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    clic_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["clic_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Clic"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    cloc_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["cloc_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Cloc"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    coco_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["coco_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Coco"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    keycloak_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["keycloak_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Keycloak"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
    tcexberry_service_logs = {
      cloudwatch_log    = "${local.cloudwatch_prefix["tcexberry_service_logs"]}"
      retention_in_days = 90
      log_tags = {
        env        = local.env
        Name       = "${local.env}-new-Cloudwatch-Logs-Tcexberry"
        ExportToS3 = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
  }
}
