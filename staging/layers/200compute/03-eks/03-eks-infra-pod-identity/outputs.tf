output "aws_ebs_csi_pod_identity_output" {
  description = "AWS EBS CSI Pod Identity"
  value       = module.aws_ebs_csi_pod_identity
}

output "aws_lb_controller_pod_identity_output" {
  description = "AWS LB Controller Pod Identity"
  value       = module.aws_lb_controller_pod_identity
}

output "external_secrets_pod_identity_output" {
  description = "AWS External Secrets Pod Identity"
  value       = module.external_secrets_pod_identity
}

output "external_dns_pod_identity_output" {
  description = "External DNS Pod Identity"
  value       = module.external_dns_pod_identity
}

output "guardduty_pod_identity_output" {
  description = "Guardduty AGent Pod Identity"
  value       = module.guardduty_pod_identity
}

