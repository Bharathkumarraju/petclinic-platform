resource "aws_dms_endpoint" "exchangedb" {
  endpoint_id   = "exchangedb"
  endpoint_type = "source"
  engine_name   = local.source_type
  port          = local.source_port
  ssl_mode      = "none"
  server_name   = local.source_cluster
  username      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.exchangedba-creds.secret_string)["username"])
  password      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.exchangedba-creds.secret_string)["password"])

  tags = local.tags
}

output "source_endpoint_id" {
  value = aws_dms_endpoint.exchangedb.endpoint_id
}
output "source_endpoint_arn" {
  value = aws_dms_endpoint.exchangedb.endpoint_arn
}

resource "aws_dms_endpoint" "riskdb" {
  endpoint_id   = "riskdb-${local.env}"
  endpoint_type = "target"
  engine_name   = local.target_type
  port          = local.target_port
  ssl_mode      = "none"
  server_name   = local.target_cluster
  username      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.risk-db-creds.secret_string)["username"])
  password      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.risk-db-creds.secret_string)["password"])

  tags = local.tags
}

output "target_endpoint_id" {
  value = aws_dms_endpoint.riskdb.endpoint_id
}
output "target_endpoint_arn" {
  value = aws_dms_endpoint.riskdb.endpoint_arn
}
