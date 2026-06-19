# Key policy for Cloudwatch logs
data "aws_iam_policy_document" "cloudwatch_logs_key_sin" {
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
      type = "Service"
      #identifiers = ["vpc-flow-logs.amazonaws.com"]
      identifiers = ["logs.${local.region_map["sin"]}.amazonaws.com"]
    }

    condition {
      test = "ArnLike"
      values = [
        "arn:aws:logs:${local.region_map["sin"]}:${local.account_id}:*",
      ]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }

  }

  statement {
    sid    = "Allow use of the key by Amazon MQ"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["mq.ap-southeast-1.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["mq.ap-southeast-1.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:mq:ap-southeast-1:${local.account_id}:broker/*"]
    }
  }

  # statement {
  #   sid    = "Allow Fluent Bit Role to use the key"
  #   effect = "Allow"
  #   actions = [
  #     "kms:ReEncrypt*",
  #     "kms:GenerateDataKey*",
  #     "kms:Encrypt",
  #     "kms:DescribeKey",
  #     "kms:Decrypt"
  #   ]
  #   resources = ["*"]

  #   principals {
  #     type = "AWS"
  #     identifiers = [
  #       "arn:aws:iam::${local.account_id}:role/svc-cloudwatch-staging-sin"
  #     ]
  #   }

  # }

}
