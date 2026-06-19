{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DescribeDBProxies",
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBProxies",
        "rds:DescribeDBProxyEndpoints",
        "rds:DescribeDBProxyTargets",
        "rds:ListTagsForResource",
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters"
      ],
      "Resource": ["arn:aws:rds:ap-southeast-1:${account_id}:*:*"]
    },
    {
      "Sid": "RDSConnect",
      "Effect": "Allow",
      "Action": "rds-db:connect",
      "Resource": [
        "arn:aws:rds-db:ap-southeast-1:${account_id}:dbuser:*/*"
      ]
    },
    {
      "Sid": "GetSecretValue",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": [
        "arn:aws:secretsmanager:ap-southeast-1:${account_id}:secret:clara*",
        "arn:aws:secretsmanager:ap-southeast-1:${account_id}:secret:envoy*"

      ]
    },
    {
      "Sid": "AllowDecryptSecretValue",
      "Action": "kms:Decrypt",
      "Effect": "Allow",
      "Resource": "${kms_secrets_manager_arn}",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "secretsmanager.ap-southeast-1.amazonaws.com"
        }
      }
    }
  ]
}
