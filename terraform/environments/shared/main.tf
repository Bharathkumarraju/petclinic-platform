module "vpc" {
  source = "../../modules/vpc"

  name                = "petclinic-shared"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "rds" {
  source = "../../modules/rds"

  name              = "shared"
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.vpc.rds_sg_id

  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  max_allocated_storage   = 20
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Project     = "petclinic"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

module "dns" {
  source = "../../modules/dns"

  domain_name = "kube-hub.com"

  tags = {
    Project     = "petclinic"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  service_names = [
    "config-server",
    "discovery-server",
    "api-gateway",
    "customers-service",
    "visits-service",
    "vets-service",
    "genai-service",
    "admin-server",
  ]

  image_tag_mutability = "MUTABLE"

  tags = {
    Project     = "petclinic"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}
