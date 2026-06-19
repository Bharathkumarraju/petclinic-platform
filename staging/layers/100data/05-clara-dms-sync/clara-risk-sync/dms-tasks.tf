resource "aws_dms_replication_task" "ccp" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "ccp"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/ccp.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "margin" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "margin"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/margin.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "risk" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "risk"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/risk.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "span" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "span"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/span.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "stress" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "stress"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/stress.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "tcexberry" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "tcexberry"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/tcexberry.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}

resource "aws_dms_replication_task" "market_data" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.clara-risk.replication_instance_arn
  replication_task_id       = "market-data"
  source_endpoint_arn       = aws_dms_endpoint.exchangedb.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.riskdb.endpoint_arn
  table_mappings            = file("tasks/market-data.json")
  replication_task_settings = file("tasks/task-settings.json")
  tags                      = local.tags
}
