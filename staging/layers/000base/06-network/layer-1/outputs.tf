output "vm_sg_id_sin" {
  description = "VM Security Group id"
  value       = module.vm_sg_sin.security_group_id
}

# output "rds_proxy_id_sin" {
#   description = "RDS Proxy Security Group id"
#   value       = module.rds_proxy_sg_sin.security_group_id
# }

# output "rds_sg_id_sin" {
#   description = "RDS Security Group id"
#   value       = module.rds_sg_sin.security_group_id
# }

output "mq_internal_sg_id_sin" {
  description = "Internal MQ Security Group id"
  value       = module.mq_internal_sg_sin.security_group_id
}

output "mq_internal_alb_sg_id_sin" {
  description = "Internal MQ ALB Security Group id"
  value       = module.mq_internal_alb_sg_sin.security_group_id
}

output "mq_internal_nlb_sg_id_sin" {
  description = "Internal MQ NLB Security Group id"
  value       = module.mq_internal_nlb_sg_sin.security_group_id
}

output "mq_external_nlb_sg_id_sin" {
  description = "External MQ NLB Security Group id"
  value       = module.mq_external_nlb_sg_sin.security_group_id
}


output "ec2_teleport_db_id_sin" {
  description = "EC2 Teleport DB Service Security Group id"
  value       = module.ec2_teleport_db_sg_sin.security_group_id
}
output "ec2_cronicle_id_sin" {
  description = "EC2 Cronicle Security Group id"
  value       = module.ec2_cronicle_sg_sin.security_group_id
}
output "elastic_agent_sg_sin" {
  description = "Elastic Agent Security Group id"
  value       = module.elastic_agent_sg_sin.security_group_id
}
output "elastic_cloud_sg_sin" {
  description = "Elastic Cloud VPCE Security Group id"
  value       = module.elastic_cloud_sg_sin.security_group_id
}
output "efs_cronicle_id_sin" {
  description = "EFS Cronicle Security Group id"
  value       = module.efs_cronicle_sg_sin.security_group_id
}

output "eks_cluster_sg_id_sin" {
  description = "EKS Cluster Security Group id"
  value       = module.eks_cluster_sg_sin.security_group_id
}
# output "eks_alb_external_sg_id_sin" {
#   description = "EKS ALB External Security Group id"
#   value       = module.eks_alb_external_sg_sin.security_group_id
# }
output "sftp_sg_id_sin" {
  description = "SFTP Security Group id"
  value       = module.sftp_sg_sin.security_group_id
}
output "exberry_sg_id_sin" {
  description = "Exberry VPCE Security Group id"
  value       = module.exberry_internal_sg_sin.security_group_id
}
