output "eip_allocations_ids_sin" {
  description = "List of Elastic IPs"
  value       = aws_eip.nat_ip_sin.*.allocation_id
}
