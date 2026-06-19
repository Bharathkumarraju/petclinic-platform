data "aws_iam_policy_document" "aws_fluentbit_s3" {
  # S3 and KMS permissions for Fluent Bit
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.fluentbit_s3_bucket}/*"]
    actions   = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:HeadObject"
    ]
  }

  statement {
    sid       = "KMSKeyPermissions"
    effect    = "Allow"
    resources = ["arn:aws:kms:${local.vpc_region}:${local.account_id}:key/${local.s3_kms_key_id}"]
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
  }
}

resource "aws_iam_policy" "fluentbit" {
  name        = format("%s-fluentbit-irsa", local.eks_cluster_name)
  description = "IAM Policy for Fluent-bit Role"
  policy      = data.aws_iam_policy_document.aws_fluentbit_s3.json
}

resource "kubernetes_namespace_v1" "fluentbit" {
  metadata {
    name = "fluentbit-system"
  }
}

module "fluentbit_irsa" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/grafana/irsa"

  eks_cluster_id        = local.eks_cluster_name
  eks_oidc_provider_arn = format("arn:%s:iam::%s:oidc-provider/%s", data.aws_partition.current.partition, data.aws_caller_identity.current.account_id, replace(local.eks_oidc_provider, "https://", ""))

  kubernetes_namespace       = "fluentbit-system"
  kubernetes_service_account = "fluentbit-sa"
  irsa_iam_policies          = [aws_iam_policy.fluentbit.arn]

  depends_on = [
  kubernetes_namespace_v1.fluentbit
  ]
}

module "fluentbit" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/grafana/helm-addon"

  helm_config = {
    name             = "fluentbit"
    chart            = "fluent-bit"
    repository       = "https://fluent.github.io/helm-charts"
    version          = "0.49.1"
    namespace        = "fluentbit-system"
    description      = "Fluentbit - Fast and lightweight log processor and forwarder or Linux, OSX and BSD family operating systems"
    values = [
      templatefile("config/fluentbit-cm.yaml", {
        service_account = local.fluentbit_sa
        s3_bucket       = local.fluentbit_s3_bucket
      })
    ]
  }
  depends_on = [
    module.fluentbit_irsa
  ]
}
