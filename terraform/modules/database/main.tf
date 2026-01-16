# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "subnetdb-group"
    Environment = var.environment
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "wordpress" {
  identifier     = "${var.project_name}db"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = false

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true
  
  backup_retention_period = 0
  
  # Performance
  multi_az               = false
  deletion_protection    = false
  
  # Manutenção
  auto_minor_version_upgrade = true
  maintenance_window         = "sun:03:00-sun:04:00"

  tags = {
    Name        = "wordpressdb"
    Environment = var.environment
  }
}
