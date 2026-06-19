locals {
  ec2_public_tags_sin = {
    env              = local.env
    map-migrated     = "mig46499"
    name             = "network-test-public"
    purpose          = "Network test for public subnet"
    CreatedByTF      = "true"
    ManagedByAnsible = "true"
    UpgradeToNewAMI  = "false"
  }
  # ec2_private_tags_sin = {
  #   env              = local.env
  #   map-migrated     = "mig46499"
  #   name             = "network-test-private"
  #   purpose          = "Network test for private subnet"
  #   CreatedByTF      = "true"
  #   ManagedByAnsible = "true"
  #   UpgradeToNewAMI  = "false"
  # }
  ec2_private_tags_sin = {
    env              = local.env
    map-migrated     = "mig46499"
    name             = "cis-test-01"
    purpose          = "CIS Hardening Test Server"
    CreatedByTF      = "true"
    ManagedByAnsible = "true"
    UpgradeToNewAMI  = "false"
  }
  ec2_db_tags_sin = {
    env              = local.env
    map-migrated     = "mig46499"
    name             = "network-test-db"
    purpose          = "Network test for db subnet"
    CreatedByTF      = "true"
    ManagedByAnsible = "true"
    UpgradeToNewAMI  = "false"
  }
}
