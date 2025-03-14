/**
 * # AWS Bedrock Module
 *
 * このモジュールはAWS Bedrockのログを保存するためのS3バケットを作成します。
 */

resource "aws_s3_bucket" "bedrock_logs" {
  bucket = "${var.system_name}-${var.environment}-bedrock-logs-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.system_name}-${var.environment}-bedrock-logs"
    System      = var.system_name
    Environment = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"
    
    filter {
      prefix = ""
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

# Bedrockサービスがログを書き込むためのバケットポリシー
resource "aws_s3_bucket_policy" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowBedrockLogging"
        Effect    = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action    = [
          "s3:PutObject"
        ]
        Resource  = "${aws_s3_bucket.bedrock_logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# Bedrockのログ記録用IAMロール
resource "aws_iam_role" "bedrock_logging" {
  count = var.enable_model_invocation_logging ? 1 : 0
  name  = "${var.system_name}-${var.environment}-bedrock-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "${var.system_name}-${var.environment}-bedrock-logging-role"
    System      = var.system_name
    Environment = var.environment
  }
}

# Bedrockのログ記録用IAMポリシー
resource "aws_iam_policy" "bedrock_logging" {
  count       = var.enable_model_invocation_logging ? 1 : 0
  name        = "${var.system_name}-${var.environment}-bedrock-logging-policy"
  description = "Policy for Bedrock to write logs to CloudWatch and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.bedrock_logs[0].arn}:*"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bedrock_logs.arn}/*"
      }
    ]
  })
}

# IAMロールにポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "bedrock_logging" {
  count      = var.enable_model_invocation_logging ? 1 : 0
  role       = aws_iam_role.bedrock_logging[0].name
  policy_arn = aws_iam_policy.bedrock_logging[0].arn
}

# Bedrockモデル呼び出しのログ記録を有効にする
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_model_invocation_logging ? 1 : 0

  logging_config {
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs[0].name
      role_arn       = aws_iam_role.bedrock_logging[0].arn
    }
    s3_config {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = "model-invocation-logs/"
    }
    text_data_delivery_enabled = true
    image_data_delivery_enabled = true
  }

  depends_on = [aws_iam_role_policy_attachment.bedrock_logging]
}

# CloudWatch Logs グループ
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name              = "/aws/bedrock/${var.system_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.system_name}-${var.environment}-bedrock-logs"
    System      = var.system_name
    Environment = var.environment
  }
}