resource "aws_cloudwatch_log_group" "transfer_server_logs" {
  name              = "/aws/transfer/${local.env}/${local.sftp_ext_domain}"
  retention_in_days = 90
  kms_key_id        = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin.arn
  skip_destroy      = true
  tags = merge({
    Name       = "${local.env}-Cloudwatch-Logs"
    ExportToS3 = true
  }, local.tags)
}
resource "aws_transfer_server" "public" {
  depends_on             = [aws_eip.transfer_server_ip, aws_eip.transfer_server_ip2]
  identity_provider_type = local.identity_provider_type
  protocols              = local.protocols
  domain                 = local.domain
  endpoint_type          = local.sftp_type
  force_destroy          = local.force_destroy
  security_policy_name   = local.security_policy_name
  # logging_role           = local.logging_role // TODO: only for workflows usage

  structured_log_destinations = [
    "${aws_cloudwatch_log_group.transfer_server_logs.arn}:*"
  ]
  host_key = local.host_key

  endpoint_details {
    address_allocation_ids = [aws_eip.transfer_server_ip.id, aws_eip.transfer_server_ip2.id]
    vpc_id                 = local.main_vpc_id_sin
    subnet_ids             = [local.main_vpc_public_subnet_sin[0], local.main_vpc_public_subnet_sin[1]]
    security_group_ids     = [local.sftp_sg_id_sin]
  }
  tags = merge({
    Name = "${local.name}-sftp-server"
  }, local.tags)
}

# Create an Elastic IP1 - For the first AZ
resource "aws_eip" "transfer_server_ip" {
  domain = "vpc"
  tags = merge({
    Name = "${local.name}-sftp-server"
  }, local.tags)
}

# Create an Elastic IP2 - for the second AZ
resource "aws_eip" "transfer_server_ip2" {
  domain = "vpc"
  tags = merge({
    Name = "${local.name}-sftp-server"
  }, local.tags)
}

// TODO: might not be needed
# resource "aws_transfer_tag" "with_custom_domain_id" {
#   resource_arn = aws_transfer_server.public.arn
#   key          = "transfer:customHostname"
#   value        = local.sftp_ext_domain 
# }
