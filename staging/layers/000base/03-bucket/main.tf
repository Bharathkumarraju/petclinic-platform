data "aws_kms_key" "kms_key_sin" {
  key_id = lookup(local.buckets_generic["lambda_bucket_sin"], "kms_key_alias")
}

// Default S3 key needs to be used due to Timestream DB limitation
data "aws_kms_alias" "default_s3_key" {
  name = "alias/aws/s3"
}

data "aws_kms_key" "default_s3_key" {
  key_id = data.aws_kms_alias.default_s3_key.id
}


module "vpc_flow_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["vpc_flow_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["vpc_flow_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["vpc_flow_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["vpc_flow_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.vpc_flowlogs.json
  lifecycle_rule            = local.buckets_generic["vpc_flow_bucket_sin"]["lifecycle_rule"]
}

module "network_fw_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["network_fw_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["network_fw_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["network_fw_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["network_fw_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.network_fw_logs.json
  lifecycle_rule            = local.buckets_generic["network_fw_bucket_sin"]["lifecycle_rule"]
}

module "bucket_create_generic_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["lambda_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["lambda_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["lambda_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["lambda_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "sftp_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["sftp_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["sftp_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["sftp_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["sftp_bucket_sin"], "logging_prefix")
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.s3_sftp_replication.json
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}

module "k8sbackupbucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["k8sbackup_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["k8sbackup_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["k8sbackup_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["k8sbackup_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}

module "loadbalancer_bucket_sin" {
  source                = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-lb-log-delivery"
  bucket_name           = lookup(local.buckets_generic["loadbalancer_bucket_sin"], "bucket_name")
  bucket_tags           = lookup(local.buckets_generic["loadbalancer_bucket_sin"], "bucket_tags")
  access_logging_bucket = lookup(local.buckets_generic["loadbalancer_bucket_sin"], "access_logging_bucket")
  logging_prefix        = lookup(local.buckets_generic["loadbalancer_bucket_sin"], "logging_prefix")
  lifecycle_rule        = local.buckets_generic["loadbalancer_bucket_sin"]["lifecycle_rule"]

}

module "risk_sftp_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["risk_sftp_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["risk_sftp_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["risk_sftp_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["risk_sftp_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "rds_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["rds_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["rds_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["rds_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["rds_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "ses_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["ses_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["ses_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["ses_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["ses_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "thanos_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["thanos_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["thanos_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["thanos_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["thanos_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "app_compliance_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["app_compliance_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["app_compliance_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["app_compliance_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["app_compliance_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "dsp_sftp_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["dsp_sftp_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["dsp_sftp_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["dsp_sftp_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["dsp_sftp_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "route53_dns_query_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["route53_dns_query_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["route53_dns_query_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["route53_dns_query_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["route53_dns_query_bucket_sin"], "logging_prefix")
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.route53_query_log_bucket.json
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
}
module "cloudwatch_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["cloudwatch_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["cloudwatch_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["cloudwatch_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["cloudwatch_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  lifecycle_rule            = lookup(local.buckets_generic["cloudwatch_bucket_sin"], "lifecycle_rule")
}

module "marketdata_ts_db_logs_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic-default-encryption"
  bucket_name               = lookup(local.buckets_generic_default_encryption["marketdata_ts_db_logs_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic_default_encryption["marketdata_ts_db_logs_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic_default_encryption["marketdata_ts_db_logs_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic_default_encryption["marketdata_ts_db_logs_bucket_sin"], "logging_prefix")
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.marketdata_ts_db.json
  lifecycle_rule            = lookup(local.buckets_generic_default_encryption["marketdata_ts_db_logs_bucket_sin"], "lifecycle_rule")
  object_ownership          = "BucketOwnerEnforced"
}

module "cloudfront_logs_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["cloudfront_logs_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["cloudfront_logs_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["cloudfront_logs_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["cloudfront_logs_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  attach_policy             = true
  policy                    = data.aws_iam_policy_document.cloudfront_logs_bucket.json
  lifecycle_rule            = lookup(local.buckets_generic["cloudfront_logs_bucket_sin"], "lifecycle_rule")
}

module "adw_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["adw_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["adw_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["adw_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["adw_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  lifecycle_rule            = lookup(local.buckets_generic["adw_bucket_sin"], "lifecycle_rule")
}

module "acs_int_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["acs_int_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["acs_int_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["acs_int_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["acs_int_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  lifecycle_rule            = lookup(local.buckets_generic["acs_int_bucket_sin"], "lifecycle_rule")
}

module "acs_ext_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["acs_ext_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["acs_ext_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["acs_ext_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["acs_ext_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  lifecycle_rule            = lookup(local.buckets_generic["acs_ext_bucket_sin"], "lifecycle_rule")
}

module "swift_bucket_sin" {
  source                    = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/bucket-create-generic"
  bucket_name               = lookup(local.buckets_generic["swift_bucket_sin"], "bucket_name")
  bucket_tags               = lookup(local.buckets_generic["swift_bucket_sin"], "bucket_tags")
  access_logging_bucket     = lookup(local.buckets_generic["swift_bucket_sin"], "access_logging_bucket")
  logging_prefix            = lookup(local.buckets_generic["swift_bucket_sin"], "logging_prefix")
  bucket_encryption_key_arn = data.aws_kms_key.kms_key_sin.arn
  lifecycle_rule            = lookup(local.buckets_generic["swift_bucket_sin"], "lifecycle_rule")
}