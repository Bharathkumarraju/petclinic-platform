module "acs_ext_sftp" {
  source            = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//transfer-family//s3"
  sftp_default_port = 2222
  name              = "abex-acs-ext-sftp"
  env               = local.env
}
