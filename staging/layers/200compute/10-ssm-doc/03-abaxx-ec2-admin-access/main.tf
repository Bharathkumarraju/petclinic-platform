resource "aws_ssm_document" "abaxx-ec2-admin-access" {
  name            = "abaxx-ec2-admin-access"
  document_type   = "Session"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "1.0"
    description   = "Admin shell as ssm-user"
    sessionType   = "Standard_Stream"
    inputs = {
      runAsEnabled       = true
      runAsDefaultUser   = "ssm-user"
      idleSessionTimeout = "20"
      maxSessionDuration = "60"
      shellProfile = {
        linux = "cd ~ && bash"
      }
    }
  })

  tags = {
    Purpose = "SSM admin shell for ssm-user"
  }
}