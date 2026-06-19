module "interface_vpc_endpoints_sin" {

  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints"

  vpc_id             = local.main_vpc_id_sin
  subnet_ids         = local.main_vpc_private_subnet_sin
  security_group_ids = [module.interface_vpc_endpoint_sg_sin.security_group_id]

  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = true
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
    },
    kms = {
      service             = "kms"
      private_dns_enabled = true
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
    },
    sns = {
      service             = "sns"
      private_dns_enabled = true
    },
    eks = {
      service             = "eks"
      private_dns_enabled = true
    }
    email-smtp = {
      service             = "email-smtp"
      private_dns_enabled = true
    }
    rds = {
      service             = "rds"
      private_dns_enabled = true
    }
    sts = {
      service             = "sts"
      private_dns_enabled = true
    }
    ecr-api = {
      service             = "ecr.api"
      private_dns_enabled = true
    }
    ecr-dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
    }
    elasticfilesystem = {
      service             = "elasticfilesystem"
      private_dns_enabled = true
    }
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
    }
    firehose = {
      service             = "kinesis-firehose"
      private_dns_enabled = true
    }
    dms = {
      service             = "dms"
      private_dns_enabled = true
    }
    ebs = {
      service             = "ebs"
      private_dns_enabled = true
    }
    elb = {
      service             = "elasticloadbalancing"
      private_dns_enabled = true
    }
    guardduty = {
      service             = "guardduty"
      private_dns_enabled = true
    }
    guardduty-data = {
      service             = "guardduty-data"
      private_dns_enabled = true
    }
    inspector2 = {
      service             = "inspector2"
      private_dns_enabled = true
    }
    inspector-scan = {
      service             = "inspector-scan"
      private_dns_enabled = true
    }
    # elasticache = {
    #   service             = "elasticache"
    #   private_dns_enabled = true      
    # }
    # mq = {
    #   service             = "mq"
    #   private_dns_enabled = true
    # }
    networkfirewall = {
      service             = "network-firewall"
      private_dns_enabled = true
    }
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
    }
    # transfer = {
    #   service             = "transfer"
    #   private_dns_enabled = true
    # }
    # transferserver = {
    #   service             = "transfer.server"
    #   private_dns_enabled = true
    # }
    xray = {
      service             = "xray"
      private_dns_enabled = true
    }
    inspector2 = {
      service             = "inspector2"
      private_dns_enabled = true
    }
  }
}
