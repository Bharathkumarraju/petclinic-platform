# data "archive_file" "start_group3_dms_lambda" {
#   type        = "zip"
#   source_file = "python/startgroup3tasks.py"
#   output_path = "lambda/startgroup3tasks.zip"
# }
# data "archive_file" "start15min_dms_lambda" {
#   type        = "zip"
#   source_file = "python/start15mintasks.py"
#   output_path = "lambda/start15mintasks.zip"
# }

# ############
# #start_group3_mon_thu
# module "start_group3_mon_thu_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "start-group3-mon-thu-dms-task-lambda"
#   filename       = data.archive_file.start_group3_dms_lambda.output_path
#   description    = "start DMS Replication Task(start_group3_mon_thu)"
#   handler        = "startgroup3tasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.start_group3_mon_thu_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_GROUP3_TASK_ARN    = aws_dms_replication_task.ccp-group3.replication_task_arn
#     MARGIN_GROUP3_TASK_ARN = aws_dms_replication_task.margin-group3.replication_task_arn
#     RISK_GROUP3_TASK_ARN   = aws_dms_replication_task.risk-group3.replication_task_arn
#     SPAN_GROUP3_TASK_ARN   = aws_dms_replication_task.span-group3.replication_task_arn
#     STRESS_GROUP3_TASK_ARN = aws_dms_replication_task.stress-group3.replication_task_arn
#     kms_key_arn            = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "start DMS Replication Task Group3 Mon--Thu - ${local.env}"
#     },
#   )
# }
# output "start_group3_mon_thu_dms_lambda_arn" {
#   value       = module.start_group3_mon_thu_dms_lambda.arn
#   description = "ARN of the start_group3_mon_thu_dms_lambda."
# }

# #This rule runs tasks at 10:30:00 SGT (02:30:00 UTC), 13:30:00 SGT (05:30:00 UTC), and 09:00:00 SGT (01:00:00 UTC) from Monday to Thursday.
# resource "aws_cloudwatch_event_rule" "start_group3_mon_thu_dms_task_schedule" {
#   name                = "start-group3-mon-thu-dms-task-schedule"
#   schedule_expression = "cron(30 2,5,8 ? * MON-THU *)"
#   event_pattern       = <<EOF
# {
#   "source": ["aws.logs"],
#   "detail": {
#     "eventName": ["CreateLogGroup"]
#   }
# }
# EOF
# }
# # Define the AWS CloudWatch Event Target to associate with the rule
# resource "aws_cloudwatch_event_target" "start_group3_mon_thu_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.start_group3_mon_thu_dms_task_schedule.name
#   target_id = "start-group3-mon-thu-dms-task-target"
#   arn       = module.start_group3_mon_thu_dms_lambda.arn
# }
# # Define a permission to allow CloudWatch Events to invoke the Lambda function
# resource "aws_lambda_permission" "start_group3_mon_thu_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.start_group3_mon_thu_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.start_group3_mon_thu_dms_task_schedule.arn
# }

# ###########
# #Group3 - Friday
# module "start_group3_fri_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "start-group3-fri-dms-task-lambda"
#   filename       = data.archive_file.start_group3_dms_lambda.output_path
#   description    = "start DMS Replication Task(start_group3_FRI)"
#   handler        = "startgroup3tasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.start_group3_fri_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_GROUP3_TASK_ARN    = aws_dms_replication_task.ccp-group3.replication_task_arn
#     MARGIN_GROUP3_TASK_ARN = aws_dms_replication_task.margin-group3.replication_task_arn
#     RISK_GROUP3_TASK_ARN   = aws_dms_replication_task.risk-group3.replication_task_arn
#     SPAN_GROUP3_TASK_ARN   = aws_dms_replication_task.span-group3.replication_task_arn
#     STRESS_GROUP3_TASK_ARN = aws_dms_replication_task.stress-group3.replication_task_arn
#     kms_key_arn            = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "start DMS Replication Task Group3 FRI - ${local.env}"
#     },
#   )
# }
# output "start_group3_fri_dms_lambda_arn" {
#   value       = module.start_group3_fri_dms_lambda.arn
#   description = "ARN of the start_group3_FRI_dms_lambda."
# }
# #####
# #Group3 Tasks (SOD, ID, and EOD) - Friday
# #This rule runs tasks at 10:30:00 SGT (02:30:00 UTC), 13:30:00 SGT (05:30:00 UTC), and 15:00:00 SGT (09:00:00 UTC) on Fridays.
# resource "aws_cloudwatch_event_rule" "start_group3_fri_dms_task_schedule" {
#   name                = "start-group3-fri-dms-task-schedule"
#   schedule_expression = "cron(30 2,5,9 ? * FRI *)"
#   event_pattern       = <<EOF
# {
#   "source": ["aws.logs"],
#   "detail": {
#     "eventName": ["CreateLogGroup"]
#   }
# }
# EOF
# }
# resource "aws_cloudwatch_event_target" "start_group3_fri_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.start_group3_fri_dms_task_schedule.name
#   target_id = "start-group3-fri-dms-task-target"
#   arn       = module.start_group3_fri_dms_lambda.arn
# }
# resource "aws_lambda_permission" "start_group3_fri_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.start_group3_fri_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.start_group3_fri_dms_task_schedule.arn
# }


# ########## 15MIN - MON-THU
# module "start_15min_mon_thu_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "start-15min-mon-thu-dms-task-lambda"
#   filename       = data.archive_file.start15min_dms_lambda.output_path
#   description    = "start DMS Replication Task(start_15min_mon_thu)"
#   handler        = "start15mintasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.start_15min_mon_thu_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_15MIN_TASK_ARN       = aws_dms_replication_task.ccp-15min.replication_task_arn
#     MARGIN_15MIN_TASK_ARN    = aws_dms_replication_task.margin-15min.replication_task_arn
#     RISK_15MIN_TASK_ARN      = aws_dms_replication_task.risk-15min.replication_task_arn
#     SPAN_15MIN_TASK_ARN      = aws_dms_replication_task.span-15min.replication_task_arn
#     STRESS_15MIN_TASK_ARN    = aws_dms_replication_task.stress-15min.replication_task_arn
#     TCEXBERRY_15MIN_TASK_ARN = aws_dms_replication_task.tcexberry-15min.replication_task_arn
#     kms_key_arn              = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "start DMS Replication Task 15Min Mon--Thu - ${local.env}"
#     },
#   )
# }
# output "start_15min_mon_thu_dms_lambda_arn" {
#   value       = module.start_15min_mon_thu_dms_lambda.arn
#   description = "ARN of the start_15min_mon_thu_dms_lambda."
# }
# #15Min Tasks (Every 15 Minutes between 12:00:00 to 04:00:00) - Monday to Thursday:
# #This rule runs tasks every 15 minutes between 12:00:00 to 04:00:00 SGT (04:00:00 to 08:00:00 UTC) from Monday to Thursday.
# resource "aws_cloudwatch_event_rule" "start_15min_mon_thu_dms_task_schedule" {
#   name                = "start-15min-mon-thu-dms-task-schedule"
#   schedule_expression = "cron(0/15 2-9 ? * MON-THU *)"
#   event_pattern       = <<EOF
# {
#   "source": ["aws.logs"],
#   "detail": {
#     "eventName": ["CreateLogGroup"]
#   }
# }
# EOF
# }
# resource "aws_cloudwatch_event_target" "start_15min_mon_thu_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.start_15min_mon_thu_dms_task_schedule.name
#   target_id = "start-15min-mon-thu-dms-task-target"
#   arn       = module.start_15min_mon_thu_dms_lambda.arn
# }
# resource "aws_lambda_permission" "start_15min_mon_thu_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.start_15min_mon_thu_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.start_15min_mon_thu_dms_task_schedule.arn
# }

# #########
# #15Min - Friday
# module "start_15min_fri_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "start-15min-fri-dms-task-lambda"
#   filename       = data.archive_file.start15min_dms_lambda.output_path
#   description    = "start DMS Replication Task(start_15Min_FRI)"
#   handler        = "start15mintasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.start_15min_fri_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_15MIN_TASK_ARN       = aws_dms_replication_task.ccp-15min.replication_task_arn
#     MARGIN_15MIN_TASK_ARN    = aws_dms_replication_task.margin-15min.replication_task_arn
#     RISK_15MIN_TASK_ARN      = aws_dms_replication_task.risk-15min.replication_task_arn
#     SPAN_15MIN_TASK_ARN      = aws_dms_replication_task.span-15min.replication_task_arn
#     STRESS_15MIN_TASK_ARN    = aws_dms_replication_task.stress-15min.replication_task_arn
#     TCEXBERRY_15MIN_TASK_ARN = aws_dms_replication_task.tcexberry-15min.replication_task_arn
#     kms_key_arn              = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "start DMS Replication Task 15MIN FRI - ${local.env}"
#     },
#   )
# }
# output "start_15min_fri_dms_lambda_arn" {
#   value       = module.start_15min_fri_dms_lambda.arn
#   description = "ARN of the start_15min_FRI_dms_lambda."
# }
# #15 Min Tasks (SOD, ID, and EOD) - Friday
# #This rule runs tasks at 10:30:00 SGT (02:30:00 UTC), 13:30:00 SGT (05:30:00 UTC), and 15:00:00 SGT (09:00:00 UTC) on Fridays.
# resource "aws_cloudwatch_event_rule" "start_15min_fri_dms_task_schedule" {
#   name                = "start-15min-dms-task-schedule"
#   schedule_expression = "cron(0/15 2-6 ? * FRI *)"
#   event_pattern       = <<EOF
# {
#   "source": ["aws.logs"],
#   "detail": {
#     "eventName": ["CreateLogGroup"]
#   }
# }
# EOF
# }
# resource "aws_cloudwatch_event_target" "start_15min_fri_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.start_15min_fri_dms_task_schedule.name
#   target_id = "start-15min-fri-dms-task-target"
#   arn       = module.start_15min_fri_dms_lambda.arn
# }
# resource "aws_lambda_permission" "start_15min_fri_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.start_15min_fri_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.start_15min_fri_dms_task_schedule.arn
# }
