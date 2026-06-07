output "endpoint" {
  description = "RDS instance endpoint hostname"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "secret_arn" {
  description = "Secrets Manager secret ARN containing RDS credentials"
  value       = aws_secretsmanager_secret.rds.arn
}

output "connection_string" {
  description = "JDBC connection string for the petclinic database"
  value       = "jdbc:mysql://${aws_db_instance.this.address}:${aws_db_instance.this.port}/petclinic"
  sensitive   = true
}
