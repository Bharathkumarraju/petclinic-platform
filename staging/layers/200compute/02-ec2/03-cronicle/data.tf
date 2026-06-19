data "aws_instances" "cronicle" {
  instance_tags = {
    Name = local.app_prefix
  }
  instance_state_names = ["running"]
}
