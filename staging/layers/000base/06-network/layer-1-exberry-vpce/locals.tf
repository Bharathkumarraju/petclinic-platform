data "terraform_remote_state" "network-layer-1" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-1/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
data "terraform_remote_state" "nw-layer-0" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

locals {
  exberry_sg_id_sin = data.terraform_remote_state.network-layer-1.outputs.exberry_sg_id_sin
  vpc_subnet_ids    = data.terraform_remote_state.nw-layer-0.outputs.main_vpc_private_subnets_sin
  vpc_id            = data.terraform_remote_state.nw-layer-0.outputs.main_vpc_id_sin

  # exberry-admin-api-service-name    = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-056e4e64f1a493611"
  # exberry-exchange-api-service-name = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0ab5c701f3b00504b"
  # exberry-fix-gatewway-service-name = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0950863d6ed6d0d0a"
  # exberry-api-gateway-service-name  = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-08e98a332f43274fa"


  exberry-admin-api = {
    # env          = local.env
    Name    = "${local.env}-exberry-admin-api"
    purpose = "VPC EndPoints for Exberry VPCE"
    # map-migrated = "mig46499"
  }
  exberry-exchange-api = {
    # env          = local.env
    Name    = "${local.env}-exberry-exchange-api"
    purpose = "VPC EndPoints for Exberry VPCE"
    # map-migrated = "mig46499"
  }
  exberry-fix-gateway = {
    # env          = local.env
    Name    = "${local.env}-exberry-fix-gateway"
    purpose = "VPC EndPoints for Exberry VPCE"
    # map-migrated = "mig46499"
  }
  exberry-api-gateway = {
    # env          = local.env
    Name    = "${local.env}-exberry-api-gateway"
    purpose = "VPC EndPoints for Exberry VPCE"
    # map-migrated = "mig46499"
  }

  # ---------------------------------------- for Uat-test only - temporary ---------------------------------------

  exberry-admin-api-service-name-uat-test    = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-08500e255b65f28b5"
  exberry-exchange-api-service-name-uat-test = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0a3f4e3bc6eb8e107"
  exberry-fix-gatewway-service-name-uat-test = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0b3eb43eb5a4e8957"
  exberry-api-gateway-service-name-uat-test  = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-08672a1b67b8a9850"

  exberry-admin-api-uat-test = {
    # env          = local.env
    Name    = "${local.env}-exberry-admin-api-uat-test"
    purpose = "VPC EndPoints for Exberry VPCE UAT Test"
    # map-migrated = "mig46499"
  }
  exberry-exchange-api-uat-test = {
    # env          = local.env
    Name    = "${local.env}-exberry-exchange-api-uat-test"
    purpose = "VPC EndPoints for Exberry VPCE UAT Test"
    # map-migrated = "mig46499"
  }
  exberry-fix-gateway-uat-test = {
    # env          = local.env
    Name    = "${local.env}-exberry-fix-gateway-uat-test"
    purpose = "VPC EndPoints for Exberry VPCE UAT Test"
    # map-migrated = "mig46499"
  }
  exberry-api-gateway-uat-test = {
    # env          = local.env
    Name    = "${local.env}-exberry-api-gateway-uat-test"
    purpose = "VPC EndPoints for Exberry VPCE UAT Test"
    # map-migrated = "mig46499"
  }



}
