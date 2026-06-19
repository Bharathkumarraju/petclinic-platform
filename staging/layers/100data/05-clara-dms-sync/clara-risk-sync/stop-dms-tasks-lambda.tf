# data "archive_file" "stop_group3_dms_lambda" {
#   type        = "zip"
#   source_file = "python/stopgroup3tasks.py"
#   output_path = "lambda/stopgroup3tasks.zip"
# }
# data "archive_file" "stop15min_dms_lambda" {
#   type        = "zip"
#   source_file = "python/stop15mintasks.py"
#   output_path = "lambda/stop15mintasks.zip"
# }
# module "stop_group3_mon_thu_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "stop-group3-mon-thu-dms-task-lambda"
#   filename       = data.archive_file.stop_group3_dms_lambda.output_path
#   description    = "STOP DMS Replication Task stop_group3_mon_thu_dms_lambda"
#   handler        = "stopgroup3tasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.stop_group3_mon_thu_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_GROUP3_TASK_ARN    = aws_dms_replication_task.ccp-group3.replication_task_arn
#     MARGIN_GROUP3_TASK_ARN = aws_dms_replication_task.margin-group3.replication_task_arn
#     RISK_GROUP3_TASK_ARN   = aws_dms_replication_task.risk-group3.replication_task_arn
#     SPAN_GROUP3_TASK_ARN   = aws_dms_replication_task.span-group3.replication_task_arn
#     STRESS_GROUP3_TASK_ARN = aws_dms_replication_task.stress-group3.replication_task_arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "STOP group3_mon_thu_dms Replication Task - ${local.env}"
#     },
#   )
# }
# output "stop_group3_mon_thu_dms_lambda_arn" {
#   value       = module.stop_group3_mon_thu_dms_lambda.arn
#   description = "ARN of the stop_group3_mon_thu_dms_lambda."
# }

# # Define the AWS CloudWatch Event Rule to trigger the ccp task Lambda function
# resource "aws_cloudwatch_event_rule" "stop_group3_mon_thu_dms_task_schedule" {
#   name                = "stop-group3-mon-thu-dms-task-schedule"
#   schedule_expression = "cron(35 2,5,8 ? * MON-THU *)"
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
# resource "aws_cloudwatch_event_target" "stop_group3_mon_thu_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.stop_group3_mon_thu_dms_task_schedule.name
#   target_id = "stop-group3-mon-thu-dms-task-target"
#   arn       = module.stop_group3_mon_thu_dms_lambda.arn

# }

# # Define a permission to allow CloudWatch Events to invoke the Lambda function
# resource "aws_lambda_permission" "stop_group3_mon_thu_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.stop_group3_mon_thu_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.stop_group3_mon_thu_dms_task_schedule.arn
# }
# ###############
# # stop_group3_fri
# module "stop_group3_fri_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "stop-group3-fri-dms-task-lambda"
#   filename       = data.archive_file.stop_group3_dms_lambda.output_path
#   description    = "STOP DMS Replication Task stop_group3_fri_dms_lambda"
#   handler        = "stopgroup3tasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.stop_group3_fri_dms_lambda_IAM.arn
#   tracing_config = {
#     mode = "Active"
#   }
#   environment = {
#     CCP_GROUP3_TASK_ARN    = aws_dms_replication_task.ccp-group3.replication_task_arn
#     MARGIN_GROUP3_TASK_ARN = aws_dms_replication_task.margin-group3.replication_task_arn
#     RISK_GROUP3_TASK_ARN   = aws_dms_replication_task.risk-group3.replication_task_arn
#     SPAN_GROUP3_TASK_ARN   = aws_dms_replication_task.span-group3.replication_task_arn
#     STRESS_GROUP3_TASK_ARN = aws_dms_replication_task.stress-group3.replication_task_arn
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "STOP group3_fri_dms Replication Task - ${local.env}"
#     },
#   )
# }
# output "stop_group3_fri_dms_lambda_arn" {
#   value       = module.stop_group3_fri_dms_lambda.arn
#   description = "ARN of the stop_group3_fri_dms_lambda."
# }

# # Define the AWS CloudWatch Event Rule to trigger the ccp task Lambda function
# resource "aws_cloudwatch_event_rule" "stop_group3_fri_dms_task_schedule" {
#   name                = "stop-group3-fri-dms-task-schedule"
#   schedule_expression = "cron(35 2,5,9 ? * FRI *)"
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
# resource "aws_cloudwatch_event_target" "stop_group3_fri_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.stop_group3_fri_dms_task_schedule.name
#   target_id = "stop-group3-fri-dms-task-target"
#   arn       = module.stop_group3_fri_dms_lambda.arn
# }

# # Define a permission to allow CloudWatch Events to invoke the Lambda function
# resource "aws_lambda_permission" "stop_group3_fri_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.stop_group3_fri_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.stop_group3_fri_dms_task_schedule.arn
# }
# #############
# # STOP 15 Minute Tasks
# module "stop_15min_mon_thu_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "stop-15min-mon-thu-dms-task-lambda"
#   filename       = data.archive_file.stop15min_dms_lambda.output_path
#   description    = "STOP DMS Replication Task stop_15min_mon_thu_dms_lambda"
#   handler        = "stop15mintasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.stop_15min_mon_thu_dms_lambda_IAM.arn
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
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "STOP 15min_mon_thu_dms Replication Task - ${local.env}"
#     },
#   )
# }
# output "stop_15min_mon_thu_dms_lambda_arn" {
#   value       = module.stop_15min_mon_thu_dms_lambda.arn
#   description = "ARN of the stop_15min_mon_thu_dms_lambda."
# }

# # Define the AWS CloudWatch Event Rule to trigger the ccp task Lambda function
# resource "aws_cloudwatch_event_rule" "stop_15min_mon_thu_dms_task_schedule" {
#   name                = "stop-15min-mon-thu-dms-task-schedule"
#   schedule_expression = "cron(5/15 2-9 ? * MON-THU *)"
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
# resource "aws_cloudwatch_event_target" "stop_15min_mon_thu_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.stop_15min_mon_thu_dms_task_schedule.name
#   target_id = "stop-15min-mon-thu-dms-task-target"
#   arn       = module.stop_15min_mon_thu_dms_lambda.arn

# }

# # Define a permission to allow CloudWatch Events to invoke the Lambda function
# resource "aws_lambda_permission" "stop_15min_mon_thu_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.stop_15min_mon_thu_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.stop_15min_mon_thu_dms_task_schedule.arn
# }
# ###############
# # stop_15min_fri
# module "stop_15min_fri_dms_lambda" {
#   source         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/terraform-aws-lambda"
#   function_name  = "stop-15min-fri-dms-task-lambda"
#   filename       = data.archive_file.stop15min_dms_lambda.output_path
#   description    = "STOP DMS Replication Task stop_15min_fri_dms_lambda"
#   handler        = "stop15mintasks.lambda_handler"
#   runtime        = "python3.8"
#   memory_size    = 128
#   concurrency    = 5
#   lambda_timeout = 20
#   log_retention  = 90
#   kms_key_id     = data.terraform_remote_state.kms-cloudwatch-logs-sin.outputs.kms_key_cloudwatch_logs_sin.arn
#   role_arn       = aws_iam_role.stop_15min_fri_dms_lambda_IAM.arn
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
#   }
#   tags = merge(
#     local.tags,
#     {
#       "Name" = "STOP 15min_fri_dms Replication Task - ${local.env}"
#     },
#   )
# }
# output "stop_15min_fri_dms_lambda_arn" {
#   value       = module.stop_15min_fri_dms_lambda.arn
#   description = "ARN of the stop_15min_fri_dms_lambda."
# }

# # Define the AWS CloudWatch Event Rule to trigger the ccp task Lambda function
# resource "aws_cloudwatch_event_rule" "stop_15min_fri_dms_task_schedule" {
#   name                = "stop-15min-fri-dms-task-schedule"
#   schedule_expression = "cron(5/15 2-6 ? * FRI *)"
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
# resource "aws_cloudwatch_event_target" "stop_15min_fri_dms_task_lambda_target" {
#   rule      = aws_cloudwatch_event_rule.stop_15min_fri_dms_task_schedule.name
#   target_id = "stop-15min-fri-dms-task-target"
#   arn       = module.stop_15min_fri_dms_lambda.arn
# }

# # Define a permission to allow CloudWatch Events to invoke the Lambda function
# resource "aws_lambda_permission" "stop_15min_fri_dms_task_permission" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = module.stop_15min_fri_dms_lambda.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.stop_15min_fri_dms_task_schedule.arn
# }
