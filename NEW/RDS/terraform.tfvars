region             = "us-east-1"
 allocated_storage = "10"
identifier              = "mydb"
  engine                  = "postgres"
  engine_version          = "14.6"
  instance_class          = "db.t3.micro"
  name                    = "syoft_db"
  username                = "masterusername"
  password                = "mustbeeightcharacters"
  backup_retention_period = 1
  storage_encrypted       = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "ci-aurora-cluster-backup"
   cluster_identifier      = "aurora-cluster"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "mydb"
  master_username         = "masterusername"
  master_password         = "mustbeeightcharacters"
  preferred_backup_window = "07:00-09:00"