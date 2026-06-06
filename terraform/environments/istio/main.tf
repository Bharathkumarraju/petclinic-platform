data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "petclinic/shared/terraform.tfstate"
    region = var.aws_region
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "petclinic-istio"
  kubernetes_version = var.kubernetes_version
  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.shared.outputs.public_subnet_ids
  admin_arns         = ["arn:aws:iam::172586632398:user/bharath"]

  tags = {
    ServiceMesh = "istio-ambient"
  }
}
