resource "aws_vpc_endpoint" "elastic-cloud-endpoint" {
  vpc_id              = local.vpc_id
  private_dns_enabled = false
  service_name        = local.elastic-cloud-sg-endpoint-service-name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    local.elastic_cloud_sg_sin
  ]
  subnet_ids = tolist(local.vpc_subnet_ids)
  tags       = local.elastic-cloud-endpoint
}


