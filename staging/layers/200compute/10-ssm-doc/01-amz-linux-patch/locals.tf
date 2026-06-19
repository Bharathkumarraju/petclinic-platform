locals {
  elastic_agent_ec2 = data.terraform_remote_state.cloud-elastic-agent-amz-linux.outputs.elastic_agent_ec2_id
}