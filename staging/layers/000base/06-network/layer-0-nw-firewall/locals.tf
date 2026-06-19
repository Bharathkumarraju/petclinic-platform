locals {
  tags = {
    env          = local.env
    purpose      = "Egress Filtering using Network Firewall"
    map-migrated = "mig46499"
  }

  firewall_tags = {
    Name         = "${local.env}-firewall-sin"
    env          = local.env
    purpose      = "Egress Filtering using Network Firewall"
    map-migrated = "mig46499"
  }

  cloudwatch_tags = {
    env          = local.env
    ExportToS3   = true
    purpose      = "Egress Filtering using Network Firewall"
    map-migrated = "mig46499"
  }

  # Route table
  igw_route_table_tags = {
    Name         = "${local.env}-igw-sin"
    env          = local.env
    purpose      = "Route table for IGW to route all traffic to Network Firewall"
    map-migrated = "mig46499"
  }

  # NACL
  firewall_nacl_tags_sin = {
    Name         = "${local.env}-firewall-nacl-sin"
    env          = local.env
    purpose      = "NACL for firewall subnet"
    map-migrated = "mig46499"
  }
  cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
}
