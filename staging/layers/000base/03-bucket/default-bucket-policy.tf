# S3 Access bucket
data "aws_iam_policy_document" "s3_deny_http" {
  # Do a loop across all buckets
  for_each = { for k, v in local.buckets_generic : k => v }
  statement {
    sid    = "DenyHTTPToS3"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${local.buckets_generic["${each.key}"]["bucket_name"]}",
      "arn:aws:s3:::${local.buckets_generic["${each.key}"]["bucket_name"]}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
