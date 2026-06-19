# Key policy for S3 bucket
data "aws_iam_policy_document" "s3_bucket_key_sin" {
  statement {
    sid       = "Allow access for Key Administrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root",
        "arn:aws:iam::978134706970:role/svc-sftp-replication-s3-uat-sin" #Grant UAT account s3 replication role access to staging
      ]
    }
  }

  statement {
    sid    = "Allow access for terraform provisioner to create and tag key"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:EnableKey",
      "kms:DisableKey",
      "kms:GetKeyRotationStatus",
      "kms:EnableKeyRotation",
      "kms:DisableKeyRotation",
      "kms:ListAliases",
      "kms:CreateAliases",
      "kms:DeleteAliases",
      "kms:DescribeKey",
      "kms:ListKeys",
      "kms:GetKeyPolicy",
      "kms:PutKeyPolicy",
      "kms:ListResourceTags",
      "kms:ListRetirableGrants",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner"
      ]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["s3.${local.region_map["sin"]}.amazonaws.com"]
    }

    condition {
      test = "ArnLike"
      values = [
        "arn:aws:s3:${local.region_map["sin"]}:${local.account_id}:*",
      ]
      variable = "kms:EncryptionContext:aws:s3:arn"
    }

  }

  statement {
    sid    = "Allow use of the key by SES and Kinesis"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = ["ses.amazonaws.com",
        "firehose.amazonaws.com",
        "delivery.logs.amazonaws.com",
      "network-firewall.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow use of the key by Fluent Bit for EKS infra node groups"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:ap-southeast-1:${local.account_id}:key/0397868f-b967-4531-99bb-59b331e37236"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/abex-eks-infra-staging-eks-node-group"
      ]
    }
  }
  statement {
    sid    = "Allow use of the key by Fluent Bit for EKS application node groups"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:ap-southeast-1:${local.account_id}:key/0397868f-b967-4531-99bb-59b331e37236"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/abex-eks-app-01-staging-eks-node-group"
      ]
    }
  }

}
