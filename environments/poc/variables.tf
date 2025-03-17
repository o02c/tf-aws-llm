variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0d52744d6551d851e" # Amazon Linux 2 in ap-northeast-1
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = null
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium" # Upgraded to medium for better vector processing performance
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "vectordb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for the RDS instance in GB for autoscaling"
  type        = number
  default     = 100
}

variable "db_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Daily time range during which backups happen"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "enable_rds" {
  description = "Flag to enable or disable RDS deployment"
  type        = bool
  default     = true
}

variable "system_name" {
  description = "Name of the system"
  type        = string
  default     = "llm"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "sandbox"
}

variable "ec2_auto_stop_cron_expression" {
  description = "Cron expression for when to automatically stop the EC2 instance (UTC time)"
  type        = string
  default     = "cron(0 15 ? * MON-FRI *)"
}

variable "ec2_auto_stop_enabled" {
  description = "Whether to enable automatic stopping of the EC2 instance"
  type        = bool
  default     = true
}

variable "ec2_enable_elastic_ip" {
  description = "Whether to assign an Elastic IP to the EC2 instance"
  type        = bool
  default     = false
}

variable "dns_domain_name" {
  description = "Base domain name for DNS records"
  type        = string
  default     = "internal"
}

variable "enable_dns" {
  description = "Whether to enable DNS name resolution"
  type        = bool
  default     = true
}
