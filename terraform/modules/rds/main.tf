resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.project}-${var.name}"
  description = "DB subnet group for ${var.project}-${var.name}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.project}-${var.name}-subnet-group" })
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.project}-${var.name}-mysql8"
  family      = "mysql8.0"
  description = "Custom parameter group for ${var.project}-${var.name}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.name}-pg" })
}

resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.name}-mysql"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "petclinic"
  username = "petclinic"
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  multi_az                        = var.multi_az
  publicly_accessible             = false
  backup_retention_period         = var.backup_retention_period
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  auto_minor_version_upgrade      = true
  enabled_cloudwatch_logs_exports = ["general", "error", "slowquery"]

  tags = merge(var.tags, { Name = "${var.project}-${var.name}-mysql" })
}

resource "aws_secretsmanager_secret" "rds" {
  name        = "${var.project}/${var.name}/rds-credentials"
  description = "RDS master credentials for ${var.project}-${var.name}-mysql"

  tags = merge(var.tags, { Name = "${var.project}/${var.name}/rds-credentials" })
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = aws_db_instance.this.username
    password = random_password.master.result
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.db_name
  })
}
