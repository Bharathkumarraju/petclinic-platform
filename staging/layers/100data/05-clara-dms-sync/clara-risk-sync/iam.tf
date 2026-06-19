# resource "aws_iam_policy" "lambda_dms_policy" {
#   name        = "svc-clara-dms-sync-lambda-execution-${local.env}-policy"
#   description = "IAM policy for Lambda to start DMS replication tasks"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = ["dms:StartReplicationTask", "dms:StopReplicationTask"]
#         Effect = "Allow",
#         Resource = [aws_dms_replication_task.ccp-group3.replication_task_arn,
#           aws_dms_replication_task.margin-group3.replication_task_arn,
#           aws_dms_replication_task.risk-group3.replication_task_arn,
#           aws_dms_replication_task.span-group3.replication_task_arn,
#           aws_dms_replication_task.stress-group3.replication_task_arn,
#           aws_dms_replication_task.ccp-15min.replication_task_arn,
#           aws_dms_replication_task.margin-15min.replication_task_arn,
#           aws_dms_replication_task.risk-15min.replication_task_arn,
#           aws_dms_replication_task.span-15min.replication_task_arn,
#           aws_dms_replication_task.stress-15min.replication_task_arn,
#           aws_dms_replication_task.tcexberry-15min.replication_task_arn
#         ]
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "xray:PutTraceSegments",
#           "xray:PutTelemetryRecords"
#         ],
#         "Resource" : [module.start_group3_mon_thu_dms_lambda.arn,
#           module.start_group3_fri_dms_lambda.arn,
#           module.start_15min_mon_thu_dms_lambda.arn,
#           module.start_15min_fri_dms_lambda.arn,
#           module.stop_group3_mon_thu_dms_lambda.arn,
#           module.stop_group3_fri_dms_lambda.arn,
#           module.stop_15min_mon_thu_dms_lambda.arn,
#           module.stop_15min_fri_dms_lambda.arn
#         ]
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "kms:Encrypt",
#           "kms:Decrypt"
#         ],
#         "Resource" : data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
#       },
#       {
#         Action : [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Effect : "Allow",
#         Resource : "*"
#       }
#     ]
#   })
# }
# ############
# ################## ---- start_group3_mon_thu_dms_lambda_IAM Role  

# resource "aws_iam_role" "start_group3_mon_thu_dms_lambda_IAM" {
#   name = "start_group3_mon_thu_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "start_group3_mon_thu_dms_lambda_IAM_default" {
#   name       = "start_group3_mon_thu_dms_lambdaIAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.start_group3_mon_thu_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "start_group3_mon_thu_dms_lambda_IAM_exec" {
#   name       = "start_group3_mon_thu_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.start_group3_mon_thu_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- start_group3_fri_dms_lambda_IAM Role  

# resource "aws_iam_role" "start_group3_fri_dms_lambda_IAM" {
#   name = "start_group3_fri_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "start_group3_fri_dms_lambda_IAM_default" {
#   name       = "start_group3_fri_dms_lambdaIAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.start_group3_fri_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "start_group3_fri_dms_lambda_IAM_exec" {
#   name       = "start_group3_fri_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.start_group3_fri_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- start_15min_mon_thu_dms_lambda_IAM Role  

# resource "aws_iam_role" "start_15min_mon_thu_dms_lambda_IAM" {
#   name = "start_15min_mon_thu_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "start_15min_mon_thu_dms_lambda_IAM_default" {
#   name       = "start_15min_mon_thu_dms_lambdaIAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.start_15min_mon_thu_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "start_15min_mon_thu_dms_lambda_IAM_exec" {
#   name       = "start_15min_mon_thu_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.start_15min_mon_thu_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- start_15min_fri_dms_lambda_IAM Role  

# resource "aws_iam_role" "start_15min_fri_dms_lambda_IAM" {
#   name = "start_15min_fri_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "start_15min_fri_dms_lambda_IAM_default" {
#   name       = "start_15min_fri_dms_lambdaIAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.start_15min_fri_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "start_15min_fri_dms_lambda_IAM_exec" {
#   name       = "start_15min_fri_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.start_15min_fri_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- stop_15min_mon_thu_dms_lambda_IAM Role  

# resource "aws_iam_role" "stop_15min_mon_thu_dms_lambda_IAM" {
#   name = "stop_15min_mon_thu_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "stop_15min_mon_thu_dms_lambda_IAM_default" {
#   name       = "stop_15min_mon_thu_dms_lambda_IAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.stop_15min_mon_thu_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "stop_15min_mon_thu_dms_lambda_IAM_exec" {
#   name       = "stop_15min_mon_thu_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.stop_15min_mon_thu_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- stop_15min_fri_dms_lambda_IAM Role  

# resource "aws_iam_role" "stop_15min_fri_dms_lambda_IAM" {
#   name = "stop_15min_fri_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "stop_15min_fri_dms_lambda_IAM_default" {
#   name       = "stop_15min_fri_dms_lambda_IAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.stop_15min_fri_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "stop_15min_fri_dms_lambda_IAM_exec" {
#   name       = "stop_15min_fri_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.stop_15min_fri_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- stop_group3_mon_thu_dms_lambda_IAM Role  

# resource "aws_iam_role" "stop_group3_mon_thu_dms_lambda_IAM" {
#   name = "stop_group3_mon_thu_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "stop_group3_mon_thu_dms_lambda_IAM_default" {
#   name       = "stop_group3_mon_thu_dms_lambda_IAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.stop_group3_mon_thu_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "stop_group3_mon_thu_dms_lambda_IAM_exec" {
#   name       = "stop_group3_mon_thu_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.stop_group3_mon_thu_dms_lambda_IAM.name]
# }

# ###################################################

# ################## ---- stop_group3_fri_dms_lambda_IAM Role  

# resource "aws_iam_role" "stop_group3_fri_dms_lambda_IAM" {
#   name = "stop_group3_fri_dms_lambda_IAM"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_iam_policy_attachment" "stop_group3_fri_dms_lambda_IAM_default" {
#   name       = "stop_group3_fri_dms_lambda_IAM-${local.env}-policy-attachment1"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   roles      = [aws_iam_role.stop_group3_fri_dms_lambda_IAM.name]
# }
# resource "aws_iam_policy_attachment" "stop_group3_fri_dms_lambda_IAM_exec" {
#   name       = "stop_group3_fri_dms_lambda_IAM_exec-${local.env}-policy-attachment2"
#   policy_arn = aws_iam_policy.lambda_dms_policy.arn
#   roles      = [aws_iam_role.stop_group3_fri_dms_lambda_IAM.name]
# }

# ###################################################

