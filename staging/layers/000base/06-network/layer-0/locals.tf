locals {
  tags = {

    purpose = "Main Network"

  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  vpc_s3_endpoint_tags = {
    Purpose = "S3 VPC endpoint"
    Name    = "s3"
  }
  vpc_dynamodb_endpoint_tags = {
    Purpose = "Dynamodb VPC endpoint"
    Name    = "dynamodb"
  }
  igw_tags = {
    Purpose = "Internet Gateway"
  }
  main_public_prefix = {

    Purpose = "Main VPC public subnet prefix"

  }
  main_private_prefix = {

    Purpose = "Main VPC private subnet prefix"

  }
  main_db_prefix = {

    Purpose = "Main VPC DB subnet prefix"

  }
  nat_gateway_tags = {
    purpose = "NAT Gateway"
    Name    = "${local.env}-main-sin-${local.region_map["sin"]}a"
  }
}
