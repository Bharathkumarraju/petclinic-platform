# // Teleport Cloud 

# data "template_file" "teleport_cloud_db_user_data" {
#   template = local.teleport_cloud_db_template
#   vars = {
#     "env" = local.env
#   }
# }

# resource "aws_launch_template" "teleport_cloud_db_service" {
#   lifecycle {
#     create_before_destroy = true
#   }
#   //name_prefix   = "${local.cluster_prefix}-db-service-"
#   name_prefix   = "teleport-cloud-db-service-"
#   image_id      = data.aws_ami.ubuntu_golden_image.image_id
#   instance_type = local.db_instance_type
#   user_data     = base64encode(data.template_file.teleport_cloud_db_user_data.rendered)
#   metadata_options {
#     http_endpoint          = "enabled"
#     http_tokens            = "required"
#     instance_metadata_tags = "enabled"
#   }
#   block_device_mappings {
#     device_name = "/dev/sda1"
#     ebs {
#       volume_type = "gp3"
#       encrypted   = true
#       kms_key_id  = local.kms_ec2_ebs
#       volume_size = 50
#     }
#   }
#   key_name      = local.key_name
#   ebs_optimized = true // check before enabling this
#   monitoring {
#     enabled = true
#   }
#   network_interfaces {
#     associate_public_ip_address = false
#     security_groups             = [local.ec2_teleport_db_id_sin]
#   }
#   iam_instance_profile {
#     name = local.ec2_teleport_db_inst_profile_sin
#   }
# }

# resource "aws_autoscaling_group" "teleport_cloud_db_service" {
#   //name                      = "${local.cluster_prefix}-db-service-asg"
#   name                      = "teleport-cloud-db-service-asg"
#   max_size                  = 2
#   min_size                  = 1
#   desired_capacity          = 1
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   force_delete              = false
#   launch_template {
#     id      = aws_launch_template.teleport_cloud_db_service.id
#     version = "$Latest"
#   }
#   vpc_zone_identifier = local.main_vpc_private_subnets_sin

#   dynamic "tag" {
#     for_each = local.ec2_tags_sin
#     content {
#       key                 = tag.key
#       value               = tag.value
#       propagate_at_launch = true
#     }
#   }
#   // external autoscale algos can modify these values,
#   // so ignore changes to them
#   lifecycle {
#     ignore_changes = [
#       desired_capacity,
#       max_size,
#       min_size,
#     ]
#   }
# }

