output "prometheus_irsa_role_arn" {
  description = "IRSA role ARN for the Prometheus service account"
  value       = aws_iam_role.prometheus.arn
}

output "grafana_irsa_role_arn" {
  description = "IRSA role ARN for the Grafana service account"
  value       = aws_iam_role.grafana.arn
}

output "ebs_csi_role_arn" {
  description = "IRSA role ARN for the EBS CSI controller (used by PersistentVolumes)"
  value       = aws_iam_role.ebs_csi.arn
}
