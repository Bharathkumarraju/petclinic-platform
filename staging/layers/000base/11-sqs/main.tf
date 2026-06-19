# Create SQS to ingest ELB logs
module "elastic_elb" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_elb"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_elb"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_elb"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_elb"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_elb"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_elb"]["sqs_name"]}-dlq"

}

resource "aws_s3_bucket_notification" "elastic_elb_event_notify" {
  bucket = local.sqs_queue["elastic_elb"]["s3_bucket"]

  queue {
    id        = "${module.elastic_elb.queue_name}-notify"
    queue_arn = module.elastic_elb.queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# Create SQS to ingest SES logs
module "elastic_ses" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_ses"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_ses"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_ses"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_ses"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_ses"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_ses"]["sqs_name"]}-dlq"

}


resource "aws_s3_bucket_notification" "elastic_ses_event_notify" {
  bucket = local.sqs_queue["elastic_ses"]["s3_bucket"]

  dynamic "queue" {
    for_each = toset(local.sqs_queue["elastic_ses"]["bucket_list_prefix"])
    content {
      id            = queue.value
      queue_arn     = module.elastic_ses.queue_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = queue.value
    }
  }
}

# Create SQS to ingest VPC Flow logs
module "elastic_vpc" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_vpc"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_vpc"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_vpc"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_vpc"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_vpc"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_vpc"]["sqs_name"]}-dlq"

}


# resource "aws_s3_bucket_notification" "elastic_vpc_event_notify" {
#   bucket = local.sqs_queue["elastic_vpc"]["s3_bucket"]

#   dynamic "queue" {
#     for_each = toset(local.sqs_queue["elastic_vpc"]["bucket_list_prefix"])
#     content {
#       id            = queue.value
#       queue_arn     = module.elastic_vpc.queue_arn
#       events        = ["s3:ObjectCreated:*"]
#       filter_prefix = queue.value
#     }
#   }
# }

# Create SQS to ingest network firewall logs
module "elastic_nfw" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_nfw"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_nfw"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_nfw"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_nfw"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_nfw"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_nfw"]["sqs_name"]}-dlq"

}

resource "aws_s3_bucket_notification" "elastic_nfw_event_notify" {
  bucket = local.sqs_queue["elastic_nfw"]["s3_bucket"]

  queue {
    id        = "${module.elastic_nfw.queue_name}-notify"
    queue_arn = module.elastic_nfw.queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# Create SQS to ingest Route53 DNS querylogs
module "elastic_r53" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_r53"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_r53"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_r53"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_r53"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_r53"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_r53"]["sqs_name"]}-dlq"

}

resource "aws_s3_bucket_notification" "elastic_r53_event_notify" {
  bucket = local.sqs_queue["elastic_r53"]["s3_bucket"]

  queue {
    id        = "${module.elastic_r53.queue_name}-notify"
    queue_arn = module.elastic_r53.queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# Create SQS to ingest Cloudwatch rds_general related logs
module "elastic_cw_rds_general" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_cw_rds_general"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_cw_rds_general"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_cw_rds_general"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_cw_rds_general"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_cw_rds_general"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_cw_rds_general"]["sqs_name"]}-dlq"

}

# Create SQS to ingest Cloudwatch rds_audit related logs
module "elastic_cw_rds_audit" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_cw_rds_audit"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_cw_rds_audit"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_cw_rds_audit"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_cw_rds_audit"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_cw_rds_audit"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_cw_rds_audit"]["sqs_name"]}-dlq"

}

# Create SQS to ingest timestreamdb
module "elastic_marketdata_ts_db_logs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = ">= 4.2.0"

  name                       = local.sqs_queue["elastic_marketdata_ts_db_logs"]["sqs_name"]
  kms_master_key_id          = local.sqs_queue["elastic_marketdata_ts_db_logs"]["sqs_kms_key"]
  create_queue_policy        = true
  queue_policy_statements    = local.sqs_queue["elastic_marketdata_ts_db_logs"]["sqs_policy"]
  visibility_timeout_seconds = local.sqs_queue["elastic_marketdata_ts_db_logs"]["visibility_timeout_seconds"]
  tags                       = local.sqs_queue["elastic_marketdata_ts_db_logs"]["sqs_tags"]
  # Dead letter queue
  create_dlq = true
  dlq_name   = "${local.sqs_queue["elastic_marketdata_ts_db_logs"]["sqs_name"]}-dlq"

}

resource "aws_s3_bucket_notification" "elastic_marketdata_ts_db_logs_event_notify" {
  bucket = local.sqs_queue["elastic_marketdata_ts_db_logs"]["s3_bucket"]

  queue {
    id        = "${module.elastic_marketdata_ts_db_logs.queue_name}-notify"
    queue_arn = module.elastic_marketdata_ts_db_logs.queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# Event Subscription to multiple directories from the same S3 
resource "aws_s3_bucket_notification" "elastic_cw_event_notify" {
  bucket = local.cw_s3_bucket

  # RDS General Logs
  dynamic "queue" {
    for_each = toset(local.sqs_queue["elastic_cw_rds_general"]["bucket_list_prefix"])
    content {
      id            = queue.value
      queue_arn     = module.elastic_cw_rds_general.queue_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = queue.value
    }
  }

  # RDS Audit Logs
  dynamic "queue" {
    for_each = toset(local.sqs_queue["elastic_cw_rds_audit"]["bucket_list_prefix"])
    content {
      id            = queue.value
      queue_arn     = module.elastic_cw_rds_audit.queue_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = queue.value
    }
  }
}



# resource "aws_s3_bucket_notification" "elastic_vpc_event_notify" {
#   bucket = local.sqs_queue["elastic_vpc"]["s3_bucket"]

#   dynamic "queue" {
#     for_each = toset(local.sqs_queue["elastic_vpc"]["bucket_list_prefix"])
#     content {
#       id            = queue.value
#       queue_arn     = module.elastic_vpc.queue_arn
#       events        = ["s3:ObjectCreated:*"]
#       filter_prefix = queue.value
#     }
#   }
# }
