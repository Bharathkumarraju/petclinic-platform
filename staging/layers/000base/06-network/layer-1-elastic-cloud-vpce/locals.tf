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
  elastic_cloud_sg_sin = data.terraform_remote_state.network-layer-1.outputs.elastic_cloud_sg_sin
  vpc_subnet_ids       = data.terraform_remote_state.nw-layer-0.outputs.main_vpc_private_subnets_sin
  vpc_id               = data.terraform_remote_state.nw-layer-0.outputs.main_vpc_id_sin

  elastic-cloud-sg-endpoint-service-name = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0cbc6cb9bdb683a95"


  elastic-cloud-endpoint = {
    # env          = local.env
    Name    = "${local.env}-elastic-cloud-endpoint"
    purpose = "VPC EndPoints for Elastic Cloud VPCE"
    # map-migrated = "mig46499"
  }

}
