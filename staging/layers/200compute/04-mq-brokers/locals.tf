locals {
  region_prefix               = "aps1"
  cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin["arn"]
  lb_access_logs_bucket_name  = data.terraform_remote_state.bucket.outputs.loadbalancer_bucket_sin_name
  mq_internal_sg_id_sin       = data.terraform_remote_state.network-layer-1.outputs.mq_internal_sg_id_sin
  mq_internal_alb_sg_id_sin   = data.terraform_remote_state.network-layer-1.outputs.mq_internal_alb_sg_id_sin
  mq_external_nlb_sg_id_sin   = data.terraform_remote_state.network-layer-1.outputs.mq_external_nlb_sg_id_sin
  mq_internal_nlb_sg_id_sin   = data.terraform_remote_state.network-layer-1.outputs.mq_internal_nlb_sg_id_sin

}


