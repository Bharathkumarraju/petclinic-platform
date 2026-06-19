locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    #Structured to add more kinds of logs for different services
    ec2_ebs = "ec2-ebs"
  }

  kms_key = {
    ec2_ebs_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["ec2_ebs"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt EC2 EBS volumes"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.ec2_ebs_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt EC2 EBS volumes"
      }
    }
  }
}
