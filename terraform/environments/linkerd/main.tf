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

  cluster_name             = "petclinic-linkerd"
  kubernetes_version       = var.kubernetes_version
  node_ami_release_version = var.node_ami_release_version
  vpc_id                   = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.shared.outputs.public_subnet_ids
  admin_arns               = var.admin_arns

  tags = {
    ServiceMesh = "linkerd"
  }
}

resource "aws_security_group_rule" "rds_from_nodes" {
  description              = "Allow MySQL 3306 from petclinic-linkerd nodes to shared RDS"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.shared.outputs.rds_sg_id
  source_security_group_id = module.eks.eks_cluster_security_group_id
}
