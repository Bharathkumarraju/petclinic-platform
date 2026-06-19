# Key policy for EC2 EBS
data "aws_iam_policy_document" "ec2_ebs_key_sin" {
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
    sid    = "Allow access for KMS operations"
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
      "kms:DescribeKey",
      "kms:RevokeGrant",
      "kms:CreateGrant",
      "kms:ListGrants"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner",
        "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
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
      identifiers = [
        "backup.amazonaws.com",     # For EC2 Backup
        "ec2.amazonaws.com",        # For EBS Snapshot (EC2)
        "autoscaling.amazonaws.com" # For Autoscaling
      ]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:ViaService"
      values = [
        "ec2.${local.region_map["sin"]}.amazonaws.com",
        "autoscaling.${local.region_map["sin"]}.amazonaws.com"
      ]
    }
  }
}
