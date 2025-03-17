resource "aws_s3_bucket" "scripts" {
  bucket = "${var.system_name}-${var.environment}-scripts-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.system_name}-${var.environment}-scripts"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_object" "jupyterhub_config" {
  bucket = aws_s3_bucket.scripts.id
  key    = "scripts/jupyterhub_config.py"
  source = "${path.module}/scripts/jupyterhub_config.py"
  etag   = filemd5("${path.module}/scripts/jupyterhub_config.py")
}

# EC2インスタンスがS3バケットにアクセスするためのポリシーを追加
resource "aws_iam_policy" "s3_access" {
  name        = "${var.system_name}-${var.environment}-s3-access-policy"
  description = "Policy for EC2 to access S3 bucket for scripts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.scripts.arn,
          "${aws_s3_bucket.scripts.arn}/*"
        ]
      }
    ]
  })
}

# S3アクセスポリシーをIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}
