locals {
  msk_name               = "abex-msk-acs-${local.env}"
  kafka_version          = "3.8.x"
  instance_type          = "kafka.t3.small"
  num_broker_per_zone    = 1
  broker_min_volume_size = 10
  broker_max_volume_size = 50
  additional_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 9098
      to_port     = 9098
      protocol    = "tcp"
      cidr_blocks = ["172.24.0.0/21"]
      description = "Manual Configured - temp allow VPN access"
    },
    {
      type        = "ingress"
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = ["172.24.0.0/21"]
      description = "Manual Configured - temp allow VPN access"
    },
    {
      type        = "ingress"
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = ["172.24.0.0/21"]
      description = "Manual Configured - temp allow VPN access"
    },
    {
      type        = "ingress"
      from_port   = 2182
      to_port     = 2182
      protocol    = "tcp"
      cidr_blocks = ["172.24.0.0/21"]
      description = "Manual Configured - temp allow VPN access"
    }
  ]

  msk_configuration_properties = {
    "auto.create.topics.enable"      = "false"
    "default.replication.factor"     = "3"
    "min.insync.replicas"            = "2"
    "num.io.threads"                 = "8"
    "num.network.threads"            = "5"
    "num.partitions"                 = "1"
    "num.replica.fetchers"           = "2"
    "replica.lag.time.max.ms"        = "30000"
    "socket.receive.buffer.bytes"    = "102400"
    "socket.request.max.bytes"       = "104857600"
    "socket.send.buffer.bytes"       = "102400"
    "unclean.leader.election.enable" = "false"
    "message.max.bytes"              = "10485760"
    "replica.fetch.max.bytes"        = "10485760"
  }
}