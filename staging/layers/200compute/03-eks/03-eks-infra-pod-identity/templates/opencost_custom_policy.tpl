{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:HeadObject",
      "s3:List*",
      "s3:Get*"
      ],
      "Resource": [
        "arn:aws:s3:::spot-datafeed*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "${kms_key_arn}"
    }
  ]
}
