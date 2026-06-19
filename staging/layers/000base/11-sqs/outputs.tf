output "elastic_elb" {
  value = module.elastic_elb
}

output "elastic_elb_event_notify" {
  value = resource.aws_s3_bucket_notification.elastic_elb_event_notify
}

output "elastic_ses" {
  value = module.elastic_ses
}

output "elastic_ses_event_notify" {
  value = resource.aws_s3_bucket_notification.elastic_ses_event_notify
}

output "elastic_cw_rds_general" {
  value = module.elastic_cw_rds_general
}

output "elastic_cw_rds_audit" {
  value = module.elastic_cw_rds_audit
}

output "elastic_cw_event_notify" {
  value = resource.aws_s3_bucket_notification.elastic_cw_event_notify
}

output "elastic_marketdata_ts_db_logs" {
  value = module.elastic_marketdata_ts_db_logs
}