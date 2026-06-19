locals {
  mq_internal_broker_id = module.exchange.mq_internal_broker_id
  mq_external_broker_id = module.exchange.mq_external_broker_id
}

data "aws_cloudwatch_log_group" "internal_mq_audit" {
  name = "/aws/amazonmq/broker/${local.mq_internal_broker_id}/audit"
}

data "aws_cloudwatch_log_group" "internal_mq_general" {
  name = "/aws/amazonmq/broker/${local.mq_internal_broker_id}/general"
}

data "aws_cloudwatch_log_group" "external_mq_audit" {
  name = "/aws/amazonmq/broker/${local.mq_external_broker_id}/audit"
}

data "aws_cloudwatch_log_group" "external_mq_general" {
  name = "/aws/amazonmq/broker/${local.mq_external_broker_id}/general"
}

resource "null_resource" "logs_retention_internal_mq_audit" {
  depends_on = [module.exchange]

  provisioner "local-exec" {
    command = <<EOT
        DATE=`date '+%F_%H%M%S'`
        tmpfile="aws-session-file-$DATE"
        aws sts assume-role --role-arn arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner --role-session-name atlantis-assumed-session > $tmpfile
        export AWS_ACCESS_KEY_ID=`cat $tmpfile | grep -i "AccessKeyId" | awk '{print $2}' | tr -d '",'`
        export AWS_SECRET_ACCESS_KEY=`cat $tmpfile | grep -i "SecretAccessKey" | awk '{print $2}' | tr -d '",'`
        export AWS_SESSION_TOKEN=`cat $tmpfile | grep -i "SessionToken" | awk '{print $2}' | tr -d '",'`
        rm -rf $tmpfile
        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile assumed-role
        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile assumed-role
        aws configure set aws_session_token $AWS_SESSION_TOKEN --profile assumed-role
        aws configure set region ap-southeast-1 --profile assumed-role
        export AWS_DEFAULT_PROFILE=assumed-role
        export AWS_PROFILE=assumed-role
        echo "Role Assumption has completed successfully"
        export AWS_PAGER=""
        aws logs put-retention-policy --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_audit.name}" --retention-in-days 90 
        aws logs tag-log-group --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_audit.name}" --tags "ExportToS3=true"
        aws logs associate-kms-key --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_audit.name}" --kms-key-id "${local.cloudwatch_logs_encrypt_key}"
    EOT
  }
}

resource "null_resource" "logs_retention_internal_mq_general" {
  depends_on = [module.exchange]

  provisioner "local-exec" {
    command = <<EOT
        DATE=`date '+%F_%H%M%S'`
        tmpfile="aws-session-file-$DATE"
        aws sts assume-role --role-arn arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner --role-session-name atlantis-assumed-session > $tmpfile
        export AWS_ACCESS_KEY_ID=`cat $tmpfile | grep -i "AccessKeyId" | awk '{print $2}' | tr -d '",'`
        export AWS_SECRET_ACCESS_KEY=`cat $tmpfile | grep -i "SecretAccessKey" | awk '{print $2}' | tr -d '",'`
        export AWS_SESSION_TOKEN=`cat $tmpfile | grep -i "SessionToken" | awk '{print $2}' | tr -d '",'`
        rm -rf $tmpfile
        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile assumed-role
        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile assumed-role
        aws configure set aws_session_token $AWS_SESSION_TOKEN --profile assumed-role
        aws configure set region ap-southeast-1 --profile assumed-role
        export AWS_DEFAULT_PROFILE=assumed-role
        export AWS_PROFILE=assumed-role
        echo "Role Assumption has completed successfully"
        export AWS_PAGER=""
        aws logs put-retention-policy --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_general.name}" --retention-in-days 90
        aws logs tag-log-group --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_general.name}" --tags "ExportToS3=true"
        aws logs associate-kms-key --log-group-name "${data.aws_cloudwatch_log_group.internal_mq_general.name}" --kms-key-id "${local.cloudwatch_logs_encrypt_key}"        
    EOT
  }
}

resource "null_resource" "logs_retention_external_mq_general" {
  depends_on = [module.exchange]

  provisioner "local-exec" {
    command = <<EOT
        DATE=`date '+%F_%H%M%S'`
        tmpfile="aws-session-file-$DATE"
        aws sts assume-role --role-arn arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner --role-session-name atlantis-assumed-session > $tmpfile
        export AWS_ACCESS_KEY_ID=`cat $tmpfile | grep -i "AccessKeyId" | awk '{print $2}' | tr -d '",'`
        export AWS_SECRET_ACCESS_KEY=`cat $tmpfile | grep -i "SecretAccessKey" | awk '{print $2}' | tr -d '",'`
        export AWS_SESSION_TOKEN=`cat $tmpfile | grep -i "SessionToken" | awk '{print $2}' | tr -d '",'`
        rm -rf $tmpfile
        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile assumed-role
        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile assumed-role
        aws configure set aws_session_token $AWS_SESSION_TOKEN --profile assumed-role
        aws configure set region ap-southeast-1 --profile assumed-role
        export AWS_DEFAULT_PROFILE=assumed-role
        export AWS_PROFILE=assumed-role
        echo "Role Assumption has completed successfully"
        export AWS_PAGER=""
        aws logs put-retention-policy --log-group-name "${data.aws_cloudwatch_log_group.external_mq_general.name}" --retention-in-days 90
        aws logs tag-log-group --log-group-name "${data.aws_cloudwatch_log_group.external_mq_general.name}" --tags "ExportToS3=true"
        aws logs associate-kms-key --log-group-name "${data.aws_cloudwatch_log_group.external_mq_general.name}" --kms-key-id "${local.cloudwatch_logs_encrypt_key}"
    EOT
  }
}

resource "null_resource" "logs_retention_external_mq_audit" {
  depends_on = [module.exchange]

  provisioner "local-exec" {
    command = <<EOT
        DATE=`date '+%F_%H%M%S'`
        tmpfile="aws-session-file-$DATE"
        aws sts assume-role --role-arn arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner --role-session-name atlantis-assumed-session > $tmpfile
        export AWS_ACCESS_KEY_ID=`cat $tmpfile | grep -i "AccessKeyId" | awk '{print $2}' | tr -d '",'`
        export AWS_SECRET_ACCESS_KEY=`cat $tmpfile | grep -i "SecretAccessKey" | awk '{print $2}' | tr -d '",'`
        export AWS_SESSION_TOKEN=`cat $tmpfile | grep -i "SessionToken" | awk '{print $2}' | tr -d '",'`
        rm -rf $tmpfile
        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile assumed-role
        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile assumed-role
        aws configure set aws_session_token $AWS_SESSION_TOKEN --profile assumed-role
        aws configure set region ap-southeast-1 --profile assumed-role
        export AWS_DEFAULT_PROFILE=assumed-role
        export AWS_PROFILE=assumed-role
        echo "Role Assumption has completed successfully"
        export AWS_PAGER=""
        aws logs put-retention-policy --log-group-name "${data.aws_cloudwatch_log_group.external_mq_audit.name}" --retention-in-days 90
        aws logs tag-log-group --log-group-name "${data.aws_cloudwatch_log_group.external_mq_audit.name}" --tags "ExportToS3=true"
        aws logs associate-kms-key --log-group-name "${data.aws_cloudwatch_log_group.external_mq_audit.name}" --kms-key-id "${local.cloudwatch_logs_encrypt_key}"
    EOT
  }
}