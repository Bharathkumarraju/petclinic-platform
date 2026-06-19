resource "aws_dms_replication_subnet_group" "dms_subnetgroup" {
  replication_subnet_group_description = "dms replication group"
  replication_subnet_group_id          = "clara-risk-dms-${local.env}"
  subnet_ids                           = data.terraform_remote_state.network.outputs.main_vpc_db_subnets_sin
  tags = merge(
    local.tags,
    {
      "Name" = "DMS Sync Clara-Risk-${local.env}"
    },
  )
}

resource "aws_dms_replication_instance" "clara-risk" {
  auto_minor_version_upgrade   = true
  engine_version               = "3.5.3"
  availability_zone            = "ap-southeast-1c"
  multi_az                     = false
  preferred_maintenance_window = "sat:00:00-sat:05:30"
  publicly_accessible          = false
  replication_instance_class   = "dms.c5.xlarge"
  replication_instance_id      = "clara-risk-dms-${local.env}"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.dms_subnetgroup.id
  tags = merge(
    local.tags,
    {
      "Name" = "DMS Sync Clara-Risk-${local.env}"
    },
  )
  vpc_security_group_ids = [module.dms-sg.security_group_id]
}


