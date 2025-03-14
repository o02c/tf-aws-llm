variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for EC2 connectivity"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "system_name" {
  description = "Name of the system"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
