variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
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