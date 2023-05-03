provider "aws" {
  region = var.region
}

resource "aws_db_instance" "syoft" {
  allocated_storage       = var.allocated_storage
  identifier              = var.identifier 
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class 
  name                    = var.name
  username                = var.username
  password                = var.password
  backup_retention_period = var.backup_retention_period
  storage_encrypted       = var.storage_encrypted
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
}

resource "aws_kms_key" "kms" {
  description = "Encryption key for automated backups"
   
}


# resource "aws_db_parameter_group" "syoftpara" {
#   name   = "rds-pg"
#   family = "postgres"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }

#   parameter {
#     name  = "character_set_client"
#     value = "utf8"
#   }
# }

resource "aws_rds_cluster" "syoftpostgres" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "aurora-postgresql"
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = 1
  preferred_backup_window = var.preferred_backup_window
}
