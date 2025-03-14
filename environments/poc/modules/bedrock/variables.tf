variable "system_name" {
  description = "システム名"
  type        = string
}

variable "environment" {
  description = "環境名 (dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "log_retention_days" {
  description = "ログの保持期間（日数）"
  type        = number
  default     = 90
}

variable "enable_model_invocation_logging" {
  description = "Bedrockモデル呼び出しのログ記録を有効にするかどうか"
  type        = bool
  default     = true
}
