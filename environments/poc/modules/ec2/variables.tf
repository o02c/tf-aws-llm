variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = null
}

variable "system_name" {
  description = "Name of the system"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "auto_stop_cron_expression" {
  description = "Cron expression for when to automatically stop the EC2 instance (UTC time)"
  type        = string
  default     = "cron(0 15 ? * * *)"
}

variable "auto_stop_enabled" {
  description = "Whether to enable automatic stopping of the EC2 instance"
  type        = bool
  default     = true
}
