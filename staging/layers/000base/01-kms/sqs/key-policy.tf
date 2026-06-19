# Key policy for Cloudwatch logs
data "aws_iam_policy_document" "sqs_sin" {
  statement {
    sid       = "Allow access for Key Administrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root",
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
    sid    = "Allow access to SQS Queue KMS for S3"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:RetireGrant"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:s3:::*"]
    }
  }

  statement {
    sid    = "Allow access to SQS Queue KMS for SQS"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:RetireGrant"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [local.account_id]
    }
  }
  statement {
    sid    = "Allow access to SQS Queue KMS for Elastic Agent"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/svc-ec2-elastic-agent-staging-sin"
      ]
    }
  }
}
