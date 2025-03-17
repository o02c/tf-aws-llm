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

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for the RDS instance in GB for autoscaling"
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily time range during which backups happen"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "dns_zone_id" {
  description = "Route 53 private zone ID for DNS record creation"
  type        = string
  default     = ""
}

variable "dns_domain_name" {
  description = "Domain name for the DNS record"
  type        = string
  default     = ""
}

variable "create_dns_record" {
  description = "Whether to create a DNS record for the RDS instance"
  type        = bool
  default     = false
}
