# PostgreSQL parameter group for pgvector extension
resource "aws_db_parameter_group" "postgres_vector" {
  name   = "${var.system_name}-${var.environment}-postgres-vector"
  family = "postgres15"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pgvector"
  }

  tags = {
    Name = "${var.system_name}-${var.environment}-postgres-vector"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.system_name}-${var.environment}-db-instance"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type           = "gp3"
  engine                 = "postgres"
  engine_version         = "15.5"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgres_vector.name
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  publicly_accessible    = false  # プライベートサブネットに配置するため、パブリックアクセスを無効化
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  apply_immediately      = true

  tags = {
    Name = "${var.system_name}-${var.environment}-db-instance"
  }
}

# This null_resource will be used to initialize the pgvector extension after the database is created
resource "null_resource" "setup_pgvector" {
  depends_on = [aws_db_instance.main]

  # This will only run when the trigger changes, which happens when the DB instance is created or updated
  triggers = {
    db_instance_id = aws_db_instance.main.id
  }

  # This provisioner will only run locally during terraform apply
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for database to be available..."
      sleep 60
      PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -c "CREATE EXTENSION IF NOT EXISTS vector;"
      echo "pgvector extension installed successfully"
    EOT
  }
}

# RDSインスタンス用のDNSレコード（オプション）
resource "aws_route53_record" "rds" {
  count   = var.create_dns_record && var.dns_zone_id != "" ? 1 : 0
  zone_id = var.dns_zone_id
  name    = "db.${var.dns_domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.main.address]
}
