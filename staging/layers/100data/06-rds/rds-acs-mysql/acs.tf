module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "abex-acs-aps1-staging"

  engine                = "mysql"
  engine_version        = "8.4"
  instance_class        = "db.m7g.large"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  ca_cert_identifier    = "rds-ca-rsa4096-g1"
  kms_key_id            = aws_kms_key.acs-kms.arn
  username              = "acs_dba"
  port                  = "3306"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [module.acs_sg.security_group_id]

  maintenance_window            = "Sun:05:00-Sun:06:00"
  master_user_secret_kms_key_id = "687e0a87-87cd-418a-a5af-6bf231e3d4c6"
  # DB subnet group
  db_subnet_group_name = "staging-main-sin"

  # DB parameter group
  family = "mysql8.4"

  # DB option group
  major_engine_version = "8.4"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}


module "acs_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "acs_sg"
  description = "Security group for ACS MySQL DB"
  vpc_id      = "vpc-0577c9310720453e9"
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Private Subnet access to ACS MySQL DB"
      cidr_blocks = "10.40.8.0/23"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Private Subnet access to ACS MySQL DB"
      cidr_blocks = "10.40.10.0/23"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Private Subnet access to ACS MySQL DB"
      cidr_blocks = "10.40.12.0/23"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Private Subnet access to ACS MySQL DB"
      cidr_blocks = "172.24.0.0/21"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "acs-kms-alias" {
  name          = "alias/kms-acs-rds-staging-sin"
  target_key_id = aws_kms_key.acs-kms.key_id
}

resource "aws_kms_key" "acs-kms" {
  description             = "KMS Key used for encrypting ACS MySQL DB storage and logs"
  enable_key_rotation     = true
  rotation_period_in_days = 365
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for terraform provisioner to create and tag key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::993533333148:role/abaxx-exch-terraform-provisioner"
        },
        Action = [
          "kms:UntagResource",
          "kms:TagResource",
          "kms:ReEncrypt*",
          "kms:PutKeyPolicy",
          "kms:ListRetirableGrants",
          "kms:ListResourceTags",
          "kms:ListKeys",
          "kms:ListAliases",
          "kms:GetKeyRotationStatus",
          "kms:GetKeyPolicy",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:EnableKeyRotation",
          "kms:EnableKey",
          "kms:DisableKeyRotation",
          "kms:DisableKey",
          "kms:DescribeKey",
          "kms:DeleteAliases",
          "kms:Decrypt",
          "kms:CreateKey",
          "kms:CreateAliases"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = [
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}
