
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "all" {

  state = "available"
}
###### Reading TF state for MQ KMS Key #######

data "terraform_remote_state" "kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/amazon_mq/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for secrets KMS Keys #######

data "terraform_remote_state" "secrets-kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/secrets_manager/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for network (VPC, subnet) #######

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for MQ Security group #######

data "terraform_remote_state" "mq-sg" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-1/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for cloudwatch KMS key #######

data "terraform_remote_state" "cloudwatch_keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/02-cloudwatch/terraform.tfstate"
    region = "ap-southeast-1"
  }
}


###### Reading TF state for IAM Services #######

data "terraform_remote_state" "iam_services" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/04-iam-services/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "rds-kms" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/rds_database/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
data "aws_kms_key" "rds_kms_key" {
  key_id = data.terraform_remote_state.rds-kms.outputs.kms_key_rds_sin["rds_db_sin"].key_id
}
data "aws_secretsmanager_secret" "exchangedba_creds" {
  name = "${local.env}/exchangedba-creds"
}

data "aws_secretsmanager_secret_version" "exchangedba_creds" {
  secret_id = data.aws_secretsmanager_secret.exchangedba_creds.id
}
data "aws_kms_key" "exchangedba_creds" {
  key_id = data.aws_secretsmanager_secret.exchangedba_creds.kms_key_id
}

data "aws_secretsmanager_secret" "exchangeviewer_creds" {
  name = "${local.env}/exchangeviewer-creds"
}
data "aws_secretsmanager_secret_version" "exchangeviewer_creds" {
  secret_id = data.aws_secretsmanager_secret.exchangeviewer_creds.id
}
data "aws_kms_key" "exchangeviewer_creds" {
  key_id = data.aws_secretsmanager_secret.exchangeviewer_creds.kms_key_id
}

data "aws_secretsmanager_secret" "clarity_db_creds" {
  name = "${local.env}/clarity-db-creds"
}
data "aws_secretsmanager_secret_version" "clarity_db_creds" {
  secret_id = data.aws_secretsmanager_secret.clarity_db_creds.id
}
data "aws_kms_key" "clarity_db_creds" {
  key_id = data.aws_secretsmanager_secret.clarity_db_creds.kms_key_id
}

data "aws_secretsmanager_secret" "keycloak_creds" {
  name = "${local.env}/keycloak-db-creds"
}
data "aws_secretsmanager_secret_version" "keycloak_creds" {
  secret_id = data.aws_secretsmanager_secret.keycloak_creds.id
}
data "aws_kms_key" "keycloak_creds" {
  key_id = data.aws_secretsmanager_secret.keycloak_creds.kms_key_id
}

data "aws_secretsmanager_secret" "eprime-db-creds" {
  name = "${local.env}/eprime-db-creds"
}
data "aws_secretsmanager_secret_version" "eprime-db-creds" {
  secret_id = data.aws_secretsmanager_secret.eprime-db-creds.id
}
data "aws_kms_key" "eprime-db-creds" {
  key_id = data.aws_secretsmanager_secret.eprime-db-creds.kms_key_id
}

data "aws_secretsmanager_secret" "mdapp_creds" {
  name = "${local.env}/mdapp-creds"
}
data "aws_secretsmanager_secret_version" "mdapp_creds" {
  secret_id = data.aws_secretsmanager_secret.mdapp_creds.id
}

data "aws_secretsmanager_secret" "mmtapp_creds" {
  name = "${local.env}/mmtapp-creds"
}
data "aws_secretsmanager_secret_version" "mmtapp_creds" {
  secret_id = data.aws_secretsmanager_secret.mmtapp_creds.id
}
data "aws_kms_key" "mmtapp_creds" {
  key_id = data.aws_secretsmanager_secret.mmtapp_creds.kms_key_id
}

data "aws_secretsmanager_secret" "mmtdba_creds" {
  name = "${local.env}/mmtdba-creds"
}
data "aws_secretsmanager_secret_version" "mmtdba_creds" {
  secret_id = data.aws_secretsmanager_secret.mmtdba_creds.id
}
data "aws_kms_key" "mmtdba_creds" {
  key_id = data.aws_secretsmanager_secret.mmtdba_creds.kms_key_id
}

data "aws_secretsmanager_secret" "mmtviewer_creds" {
  name = "${local.env}/mmtviewer-creds"
}
data "aws_secretsmanager_secret_version" "mmtviewer_creds" {
  secret_id = data.aws_secretsmanager_secret.mmtviewer_creds.id
}

data "aws_kms_key" "mmtviewer_creds" {
  key_id = data.aws_secretsmanager_secret.mmtviewer_creds.kms_key_id
}

data "aws_secretsmanager_secret" "mdviewer_creds" {
  name = "${local.env}/mdviewer-creds"
}
data "aws_secretsmanager_secret_version" "mdviewer_creds" {
  secret_id = data.aws_secretsmanager_secret.mdviewer_creds.id
}
data "aws_secretsmanager_secret" "dspupdateapp_creds" {
  name = "${local.env}/dspupdateapp-creds"
}
data "aws_secretsmanager_secret_version" "dspupdateapp_creds" {
  secret_id = data.aws_secretsmanager_secret.dspupdateapp_creds.id
}

data "aws_secretsmanager_secret" "authx_db_creds" {
  name = "${local.env}/authxapp-creds"
}
data "aws_secretsmanager_secret_version" "authx_db_creds" {
  secret_id = data.aws_secretsmanager_secret.authx_db_creds.id
}

data "aws_secretsmanager_secret" "authx_web_db_creds" {
  name = "${local.env}/authxwebapp-creds"
}
data "aws_secretsmanager_secret_version" "authx_web_db_creds" {
  secret_id = data.aws_secretsmanager_secret.authx_web_db_creds.id
}

data "aws_secretsmanager_secret" "clapi_db_creds" {
  name = "${local.env}/clapiapp-creds"
}
data "aws_secretsmanager_secret_version" "clapi_db_creds" {
  secret_id = data.aws_secretsmanager_secret.clapi_db_creds.id
}

data "aws_secretsmanager_secret" "alert_db_creds" {
  name = "${local.env}/alertapp-creds"
}
data "aws_secretsmanager_secret_version" "alert_db_creds" {
  secret_id = data.aws_secretsmanager_secret.alert_db_creds.id
}

data "aws_secretsmanager_secret" "clara_db_creds" {
  name = "${local.env}/claraapp-creds"
}
data "aws_secretsmanager_secret_version" "clara_db_creds" {
  secret_id = data.aws_secretsmanager_secret.clara_db_creds.id
}

data "aws_secretsmanager_secret" "claus_db_creds" {
  name = "${local.env}/clausapp-creds"
}
data "aws_secretsmanager_secret_version" "claus_db_creds" {
  secret_id = data.aws_secretsmanager_secret.claus_db_creds.id
}

data "aws_secretsmanager_secret" "clic_db_creds" {
  name = "${local.env}/clicapp-creds"
}
data "aws_secretsmanager_secret_version" "clic_db_creds" {
  secret_id = data.aws_secretsmanager_secret.clic_db_creds.id
}

data "aws_secretsmanager_secret" "cloc_db_creds" {
  name = "${local.env}/clocapp-creds"
}
data "aws_secretsmanager_secret_version" "cloc_db_creds" {
  secret_id = data.aws_secretsmanager_secret.cloc_db_creds.id
}

data "aws_secretsmanager_secret" "coco_db_creds" {
  name = "${local.env}/cocoapp-creds"
}
data "aws_secretsmanager_secret_version" "coco_db_creds" {
  secret_id = data.aws_secretsmanager_secret.coco_db_creds.id
}

data "aws_secretsmanager_secret" "tcexberry_db_creds" {
  name = "${local.env}/tcexberryapp-creds"
}
data "aws_secretsmanager_secret_version" "tcexberry_db_creds" {
  secret_id = data.aws_secretsmanager_secret.tcexberry_db_creds.id
}

data "aws_secretsmanager_secret" "claraviewer_db_creds" {
  name = "${local.env}/claraviewer-creds"
}
data "aws_secretsmanager_secret_version" "claraviewer_db_creds" {
  secret_id = data.aws_secretsmanager_secret.claraviewer_db_creds.id
}
