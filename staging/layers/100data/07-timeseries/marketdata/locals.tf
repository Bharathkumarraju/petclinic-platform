locals {
  db_prefix                           = "marketdata"
  influxdb_instance_type              = "db.influx.medium"
  allocated_storage                   = 40
  deployment_type                     = "SINGLE_AZ"
  tf_state_bucket                     = "abaxx-exch-tf-state-nonprod"
  additional_ingress_with_cidr_blocks = []
  bucket_log_name                     = data.terraform_remote_state.buckets.outputs.marketdata_ts_db_logs_bucket_sin_name
}
