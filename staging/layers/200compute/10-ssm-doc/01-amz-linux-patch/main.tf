resource "aws_ssm_document" "amz_linux_patch" {
  name          = "amz_linux_patch"
  document_type = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: "Updates all packages via yum and reboot the instance."
mainSteps:
  - action: aws:runShellScript
    name: patchAndReboot
    inputs:
      runCommand:
        - "yum update -y"
        - |
          echo "Patches applied. Signaling SSM for a reboot..."
          reboot
DOC
}


resource "aws_ssm_association" "amz_linux_patch_association" {
  association_name = "abaxx_amz_linux_patch_association"
  name = aws_ssm_document.amz_linux_patch.name

  schedule_expression = "cron(0 2 ? * SUN *)" # Every Sun 10 AM (GMT +8)
  apply_only_at_cron_interval = true

  targets {
    key    = "InstanceIds"
    values = [local.elastic_agent_ec2] 
  }
}