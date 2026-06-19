# Key policy for SNS
data "aws_iam_policy_document" "sns_key_sin" {
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
    sid    = "Allow access for SES to send events to SNS"
    effect = "Allow"
    actions = ["kms:GenerateDataKey*",
    "kms:Decrypt"]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com"
      ]
    }
  }
  statement {
    sid    = "Allow cloudwatch to send notifications to SNS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
    }
  }
  statement {
    sid    = "Allow RDS events to send notifications to SNS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "events.rds.amazonaws.com"
      ]
    }
  }
  statement {
    sid       = "Allow_Publish_Alarms"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["arn:aws:sns:ap-southeast-1:${local.account_id}:*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}


