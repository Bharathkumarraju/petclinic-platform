module "vpc" {
  source = "../../modules/vpc"

  name                = "petclinic-shared"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}
