locals {

  main_vpc_id_sin            = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  main_vpc_public_subnet_sin = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_sin
  sftp_sg_id_sin             = data.terraform_remote_state.network-layer-1.outputs.sftp_sg_id_sin


  sftp_ext_domain        = "sftp.${local.env}.xabx.net"
  hosted_zone            = "${local.env}.abex.int"
  host_key               = null
  security_policy_name   = "TransferSecurityPolicy-2020-06"
  name                   = "AbaxxExchange"
  sftp_type              = "VPC"
  protocols              = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
  # logging_role           = data.terraform_remote_state.iam.outputs.sftp_logging_role_sin // TODO: only for workflows usage
  force_destroy = false
  domain        = "S3"
  server_id     = aws_transfer_server.public.id
  server_ep     = aws_transfer_server.public.endpoint
  tags = {
    Name         = "Abaxx.Exchange"
    purpose      = "SFTP-S3"
    ExportToS3   = "true"
    map-migrated = "mig46499"
  }
}
