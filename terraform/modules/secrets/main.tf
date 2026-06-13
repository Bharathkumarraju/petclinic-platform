resource "aws_secretsmanager_secret" "openai" {
  name                    = "${var.project}/shared/openai-api-key"
  description             = "OpenAI API key for the GenAI service"
  recovery_window_in_days = 7

  tags = merge(var.tags, { Name = "${var.project}/shared/openai-api-key" })
}

resource "aws_secretsmanager_secret_version" "openai" {
  secret_id     = aws_secretsmanager_secret.openai.id
  secret_string = var.openai_api_key
}
