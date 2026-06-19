module "nw_test_private" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  # ami = data.aws_ami.ubuntu_golden_image.id
  ami = "ami-017878912e233e0b9"

  name                        = local.ec2_desc["nw_test_private"]["ec2_name"]
  instance_type               = local.ec2_desc["nw_test_private"]["instance_type"]
  key_name                    = local.ec2_desc["nw_test_private"]["security_key_name"]
  monitoring                  = local.ec2_desc["nw_test_private"]["monitoring"]
  vpc_security_group_ids      = local.ec2_desc["nw_test_private"]["vpc_security_group_ids"]
  subnet_id                   = local.ec2_desc["nw_test_private"]["subnet_id"]
  iam_instance_profile        = local.ec2_desc["nw_test_private"]["iam_instance_profile"]
  associate_public_ip_address = local.ec2_desc["nw_test_private"]["associate_public_ip_address"]
  # private_ip                  = local.ec2_desc["nw_test_private"]["private_ip"]
  tags               = local.ec2_desc["nw_test_private"]["tags"]
  metadata_options   = local.ec2_desc["nw_test_private"]["metadata_options"]
  root_block_device  = local.ec2_desc["nw_test_private"]["root_block_device"]
  ignore_ami_changes = true
}

module "nw_test_private_2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  # ami = data.aws_ami.ubuntu_golden_image.id
  ami = "ami-017878912e233e0b9"

  name                        = local.ec2_desc["nw_test_private"]["ec2_name"]
  instance_type               = local.ec2_desc["nw_test_private"]["instance_type"]
  key_name                    = local.ec2_desc["nw_test_private"]["security_key_name"]
  monitoring                  = local.ec2_desc["nw_test_private"]["monitoring"]
  vpc_security_group_ids      = local.ec2_desc["nw_test_private"]["vpc_security_group_ids"]
  subnet_id                   = local.ec2_desc["nw_test_private"]["subnet_id"]
  iam_instance_profile        = local.ec2_desc["nw_test_private"]["iam_instance_profile"]
  associate_public_ip_address = local.ec2_desc["nw_test_private"]["associate_public_ip_address"]
  # private_ip                  = local.ec2_desc["nw_test_private"]["private_ip"]
  tags               = local.ec2_desc["nw_test_private"]["tags"]
  metadata_options   = local.ec2_desc["nw_test_private"]["metadata_options"]
  root_block_device  = local.ec2_desc["nw_test_private"]["root_block_device"]
  ignore_ami_changes = true
}

# module "nw_test_public" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = ">= 3.0"

#   name = local.ec2_desc["nw_test_public"]["ec2_name"]
#   ami  = data.aws_ami.ubuntu_golden_image.id

#   instance_type               = local.ec2_desc["nw_test_public"]["instance_type"]
#   key_name                    = local.ec2_desc["nw_test_public"]["security_key_name"]
#   monitoring                  = local.ec2_desc["nw_test_public"]["monitoring"]
#   vpc_security_group_ids      = local.ec2_desc["nw_test_public"]["vpc_security_group_ids"]
#   subnet_id                   = local.ec2_desc["nw_test_public"]["subnet_id"]
#   iam_instance_profile        = local.ec2_desc["nw_test_public"]["iam_instance_profile"]
#   associate_public_ip_address = local.ec2_desc["nw_test_public"]["associate_public_ip_address"]
#   private_ip                  = local.ec2_desc["nw_test_public"]["private_ip"]
#   tags                        = local.ec2_desc["nw_test_public"]["tags"]
#   metadata_options            = local.ec2_desc["nw_test_public"]["metadata_options"]
#   ignore_ami_changes          = true
# }

# module "nw_test_db" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = ">= 3.0"

#   name = local.ec2_desc["nw_test_db"]["ec2_name"]
#   ami  = data.aws_ami.ubuntu_golden_image.id

#   instance_type               = local.ec2_desc["nw_test_db"]["instance_type"]
#   key_name                    = local.ec2_desc["nw_test_db"]["security_key_name"]
#   monitoring                  = local.ec2_desc["nw_test_db"]["monitoring"]
#   vpc_security_group_ids      = local.ec2_desc["nw_test_db"]["vpc_security_group_ids"]
#   subnet_id                   = local.ec2_desc["nw_test_db"]["subnet_id"]
#   iam_instance_profile        = local.ec2_desc["nw_test_db"]["iam_instance_profile"]
#   associate_public_ip_address = local.ec2_desc["nw_test_db"]["associate_public_ip_address"]
#   private_ip                  = local.ec2_desc["nw_test_db"]["private_ip"]
#   tags                        = local.ec2_desc["nw_test_db"]["tags"]
#   metadata_options            = local.ec2_desc["nw_test_db"]["metadata_options"]
#   ignore_ami_changes          = true
# }
