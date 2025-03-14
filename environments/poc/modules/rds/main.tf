resource "aws_db_instance" "main" {
  identifier             = "${var.system_name}-${var.environment}-db-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  publicly_accessible    = false  # プライベートサブネットに配置するため、パブリックアクセスを無効化

  tags = {
    Name = "${var.system_name}-${var.environment}-db-instance"
  }
}
