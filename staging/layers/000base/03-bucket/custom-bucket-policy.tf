# S3 vpc_flowlogs
data "aws_iam_policy_document" "vpc_flowlogs" {
  statement {
    sid     = "AllowVPCFlowLogs"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::abex-vpc-flow-bucket-staging-sin/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::abex-vpc-flow-bucket-staging-sin"]
  }

}

# S3 sftp replication
data "aws_iam_policy_document" "s3_sftp_replication" {
  statement {
    sid    = "AllowObjectAccess"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = [
      "arn:aws:s3:::abex-sftp-bucket-staging-sin/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::978134706970:role/svc-sftp-replication-s3-uat-sin"]
    }
  }
  statement {
    sid = "AllowBucketAccess"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::978134706970:role/svc-sftp-replication-s3-uat-sin"]
    }

    actions = [
      "s3:GetBucketVersioning",
      "s3:List*",
      "s3:PutBucketVersioning"
    ]

    resources = ["arn:aws:s3:::abex-sftp-bucket-staging-sin"]
  }

}

# S3 network_fw_logs
data "aws_iam_policy_document" "network_fw_logs" {
  statement {
    sid     = "AllowNetworkFWLogs"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::abex-network-fw-bucket-staging-sin/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["network-firewall.amazonaws.com"]
    }
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["network-firewall.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::abex-network-fw-bucket-staging-sin"]
  }

}

// Route53 DNS Query bucket policy
data "aws_iam_policy_document" "route53_query_log_bucket" {
  statement {
    sid    = "AllowRoute53ResolverLogs"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::abex-route53-dns-query-bucket-staging-sin/*",
      "arn:aws:s3:::abex-route53-dns-query-bucket-staging-sin"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::993533333148:role/aws-service-role/route53resolver.amazonaws.com/AWSServiceRoleForRoute53Resolver"]
    }
  }
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::abex-route53-dns-query-bucket-staging-sin/AWSLogs/993533333148/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["993533333148"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-southeast-1:993533333148:*"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = [
      "arn:aws:s3:::abex-route53-dns-query-bucket-staging-sin"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["993533333148"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-southeast-1:993533333148:*"]
    }
  }
}

# S3 marketdata_ts_db
data "aws_iam_policy_document" "marketdata_ts_db" {
  statement {
    sid    = "AllowTimestreamInfluxDBLogDelivery"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::abex-marketdata-ts-db-logs-bucket-sin-staging-sin/*",
      "arn:aws:s3:::abex-marketdata-ts-db-logs-bucket-sin-staging-sin"
    ]
    principals {
      type        = "Service"
      identifiers = ["timestream-influxdb.amazonaws.com"]
    }
  }
}

# S3 marketdata_ts_db
data "aws_iam_policy_document" "cloudfront_logs_bucket" {
  statement {
    sid       = "AWSCloudFrontLogDelivery"
    effect    = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::abex-cloudfront-logs-bucket-staging-sin/AWSLogs/993533333148/CloudFront/*"
    ]
    principals {
      type = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"
      values = ["arn:aws:logs:us-east-1:993533333148:delivery-source:CreatedByCloudFront-E3TWFKQTT15XKG-ACCESS_LOGS"]
    }
  }
}