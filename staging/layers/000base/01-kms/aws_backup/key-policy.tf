# Key policy for AWS Backup
data "aws_iam_policy_document" "aws_backup_key_sin" {
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

  # statement {
  #   sid    = "Allow access through Backup for all principals in the account that are authorized to use Backup Storage"
  #   effect = "Allow"
  #   actions = [
  #     "kms:CreateGrant",
  #     "kms:Decrypt",
  #     "kms:GenerateDataKey*"
  #   ]
  #   resources = ["*"]

  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }
  #   condition {
  #     test     = "ForAnyValue:StringEquals"
  #     variable = "kms:CallerAccount"
  #     values   = [local.account_id]
  #   }
  #   condition {
  #     test     = "ForAnyValue:StringEquals"
  #     variable = "kms:ViaService"
  #     values   = ["backup.${local.region_map["sin"]}.amazonaws.com"]
  #   }
  # }
  # statement {
  #   sid    = "Allow direct access to key metadata to the account"
  #   effect = "Allow"
  #   actions = [
  #     "kms:Describe*",
  #     "kms:Get*",
  #     "kms:List*",
  #     "kms:RevokeGrant"
  #   ]
  #   resources = ["*"]
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["arn:aws:iam::${local.account_id}:root"]
  #   }
  # }
}
