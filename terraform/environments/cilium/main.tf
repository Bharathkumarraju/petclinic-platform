data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket       = var.state_bucket
    key          = "petclinic/shared/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
    encrypt      = true
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "petclinic-cilium"
  kubernetes_version = var.kubernetes_version
  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.shared.outputs.public_subnet_ids
  alb_sg_id          = data.terraform_remote_state.shared.outputs.alb_sg_id

  tags = {
    ServiceMesh = "cilium"
  }
}
