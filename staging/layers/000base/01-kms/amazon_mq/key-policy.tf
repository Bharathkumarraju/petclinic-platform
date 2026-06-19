
# Key policy for MQ broker
data "aws_iam_policy_document" "mq_broker_key_sin" {
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
    sid    = "Allow MQ to use the key"
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
      identifiers = ["mq.amazonaws.com"]
    }
  }
}
