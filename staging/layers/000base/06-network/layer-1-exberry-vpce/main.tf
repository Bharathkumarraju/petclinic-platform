# resource "aws_vpc_endpoint" "exberry-admin-api" {
#   vpc_id              = local.vpc_id
#   private_dns_enabled = true
#   service_name        = local.exberry-admin-api-service-name
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     local.exberry_sg_id_sin
#   ]
#   subnet_ids = tolist(local.vpc_subnet_ids)
#   tags       = local.exberry-admin-api
# }

# resource "aws_vpc_endpoint" "exberry-exchange-api" {
#   vpc_id              = local.vpc_id
#   private_dns_enabled = true
#   service_name        = local.exberry-exchange-api-service-name
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     local.exberry_sg_id_sin
#   ]
#   subnet_ids = tolist(local.vpc_subnet_ids)
#   tags       = local.exberry-exchange-api
# }

# resource "aws_vpc_endpoint" "exberry-fix-gateway" {
#   vpc_id              = local.vpc_id
#   private_dns_enabled = true
#   service_name        = local.exberry-fix-gatewway-service-name
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     local.exberry_sg_id_sin
#   ]
#   subnet_ids = tolist(local.vpc_subnet_ids)
#   tags       = local.exberry-fix-gateway
# }
# resource "aws_vpc_endpoint" "exberry-api-gateway" {
#   vpc_id              = local.vpc_id
#   private_dns_enabled = true
#   service_name        = local.exberry-api-gateway-service-name
#   vpc_endpoint_type   = "Interface"
#   security_group_ids = [
#     local.exberry_sg_id_sin
#   ]
#   subnet_ids = tolist(local.vpc_subnet_ids)
#   tags       = local.exberry-api-gateway
# }

# ------------------------------------------UAT -Test only -----------------------------

resource "aws_vpc_endpoint" "exberry-admin-api-uat-test" {
  vpc_id              = local.vpc_id
  private_dns_enabled = true
  service_name        = local.exberry-admin-api-service-name-uat-test
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    local.exberry_sg_id_sin
  ]
  subnet_ids = tolist(local.vpc_subnet_ids)
  tags       = local.exberry-admin-api-uat-test
}

resource "aws_vpc_endpoint" "exberry-exchange-api-uat-test" {
  vpc_id              = local.vpc_id
  private_dns_enabled = true
  service_name        = local.exberry-exchange-api-service-name-uat-test
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    local.exberry_sg_id_sin
  ]
  subnet_ids = tolist(local.vpc_subnet_ids)
  tags       = local.exberry-exchange-api-uat-test
}

resource "aws_vpc_endpoint" "exberry-fix-gateway-uat-test" {
  vpc_id              = local.vpc_id
  private_dns_enabled = true
  service_name        = local.exberry-fix-gatewway-service-name-uat-test
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    local.exberry_sg_id_sin
  ]
  subnet_ids = tolist(local.vpc_subnet_ids)
  tags       = local.exberry-fix-gateway-uat-test
}
resource "aws_vpc_endpoint" "exberry-api-gateway-uat-test" {
  vpc_id              = local.vpc_id
  private_dns_enabled = true
  service_name        = local.exberry-api-gateway-service-name-uat-test
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    local.exberry_sg_id_sin
  ]
  subnet_ids = tolist(local.vpc_subnet_ids)
  tags       = local.exberry-api-gateway-uat-test
}
