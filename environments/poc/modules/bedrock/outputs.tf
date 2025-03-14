output "bedrock_logs_bucket_id" {
  description = "Bedrockログ用S3バケットのID"
  value       = aws_s3_bucket.bedrock_logs.id
}

output "bedrock_logs_bucket_arn" {
  description = "Bedrockログ用S3バケットのARN"
  value       = aws_s3_bucket.bedrock_logs.arn
}

output "bedrock_logs_bucket_domain_name" {
  description = "Bedrockログ用S3バケットのドメイン名"
  value       = aws_s3_bucket.bedrock_logs.bucket_domain_name
}
