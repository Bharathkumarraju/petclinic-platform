locals {
  test_ec2_security_group = data.terraform_remote_state.network-layer-1.outputs.elastic_agent_sg_sin
  #  test_ext_ec2_security_group = data.terraform_remote_state.network-layer-1.outputs.test_ext_ec2_sg_id_sin
  test_ec2_iam_profile = data.terraform_remote_state.iam.outputs.ec2_default_service_inst_profile_sin

  ec2_desc = {
    nw_test_private = {
      ec2_name                    = local.ec2_private_tags_sin["name"]
      instance_type               = "t3.medium"
      security_key_name           = "ansible-abaxx-key"
      monitoring                  = false
      vpc_security_group_ids      = [local.test_ec2_security_group]
      subnet_id                   = local.subnet_map["sin"]["main_vpc_private_subnets"][0]
      iam_instance_profile        = local.test_ec2_iam_profile
      associate_public_ip_address = false
      #private_ip                  = "10.40.8.25"
      #  user_data_base64            = base64encode(local.user_data_private)
      #  user_data_replace_on_change = true    
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 125
          volume_size = 20
          kms_key_id  = local.common_kms_key_ec2_ebs_id
        },
      ]
      tags = local.ec2_private_tags_sin
      metadata_options = {
        instance_metadata_tags = "enabled"
      }
    },
    # nw_test_public = {
    #   ec2_name                    = local.ec2_public_tags_sin["name"]
    #   instance_type               = "t2.micro"
    #   security_key_name           = "test-abaxx-key"
    #   monitoring                  = false
    #   vpc_security_group_ids      = [local.test_ext_ec2_security_group]
    #   subnet_id                   = local.subnet_map["sin"]["main_vpc_public_subnets"][0]
    #   iam_instance_profile        = local.test_ec2_iam_profile
    #   associate_public_ip_address = true
    #   private_ip                  = "10.40.0.25"
    #   #  user_data_base64            = base64encode(local.user_data_private)
    #   #  user_data_replace_on_change = true      
    #   tags = local.ec2_public_tags_sin
    #   metadata_options = {
    #     instance_metadata_tags = "enabled"
    #   }
    # },
    # nw_test_db = {
    #   ec2_name                    = local.ec2_db_tags_sin["name"]
    #   instance_type               = "t2.micro"
    #   security_key_name           = "test-abaxx-key"
    #   monitoring                  = false
    #   vpc_security_group_ids      = [local.test_ec2_security_group]
    #   subnet_id                   = local.subnet_map["sin"]["main_vpc_db_subnets"][0]
    #   iam_instance_profile        = local.test_ec2_iam_profile
    #   associate_public_ip_address = false
    #   private_ip                  = "10.40.4.25"
    #   #  user_data_base64            = base64encode(local.user_data_private)
    #   #  user_data_replace_on_change = true      
    #   tags = local.ec2_db_tags_sin
    #   metadata_options = {
    #     instance_metadata_tags = "enabled"
    #   }
    # },
  }


}






