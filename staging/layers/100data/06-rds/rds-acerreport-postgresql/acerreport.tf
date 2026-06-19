# module "rds_acerreport" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/rds/rds-psql-instance"

#   env            = local.env
#   engine_version = local.engine_version
#   app            = local.app
#   repository     = local.repository
# }

# # PostgreSQL Database Configuration for acerreport
# # This module creates database roles, schemas, and access control
# module "rds_acerreport_config" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/rds/rds-psql-db-config"

#   app         = local.app
#   environment = local.env

#   # Database and schema configuration
#   database_name = "acer_report"
#   schema_name   = "acer_report"

#   # RDS instance connection details
#   master_username      = module.rds_acerreport.db_instance_username
#   db_instance_endpoint = module.rds_acerreport.db_instance_address
#   db_instance_port     = 5432

#   # KMS key for encrypting secrets
#   secrets_kms_key_id = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn

#   # Connection limits
#   migration_role_connection_limit = 5
#   app_role_connection_limit       = -1 # unlimited

#   # Application role privileges
#   app_role_table_privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]

#   # Grant on existing objects (set to true if database already has tables)
#   grant_on_existing_objects = false

#   # Password rotation version
#   password_version = "1"

#   # Recovery window for deleted secrets
#   recovery_window_in_days = 7

#   # Tags
#   tags = {
#     env         = local.env
#     application = local.app
#     repository  = local.repository
#     managed_by  = "terraform"
#   }

#   depends_on = [module.rds_acerreport]
# }
