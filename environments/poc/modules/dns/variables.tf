variable "system_name" {
  description = "Name of the system"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for DNS records"
  type        = string
  default     = "internal"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
