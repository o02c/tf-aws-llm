# IAM role for EC2 instance (Bedrock access, S3 access, etc.)
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.system_name}-${var.environment}-ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.system_name}-${var.environment}-ec2-instance-role"
  }
}

# Create IAM policy for Bedrock access
resource "aws_iam_policy" "bedrock_policy" {
  name        = "${var.system_name}-${var.environment}-bedrock-policy"
  description = "Policy for EC2 to access AWS Bedrock services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel",
          "bedrock:ListCustomModels",
          "bedrock:GetCustomModel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock-runtime:InvokeModel",
          "bedrock-runtime:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.system_name}-${var.environment}-bedrock-policy"
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the Bedrock policy to the role
resource "aws_iam_role_policy_attachment" "bedrock_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.system_name}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/scripts/user_data.sh.tpl", {
    s3_bucket_name = aws_s3_bucket.scripts.id
  })

  tags = {
    Name = "${var.system_name}-${var.environment}-instance"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

# Elastic IP (optional)
resource "aws_eip" "instance" {
  count = var.enable_elastic_ip ? 1 : 0
  domain = "vpc"
  
  tags = {
    Name = "${var.system_name}-${var.environment}-eip"
  }
}

# Elastic IP association (optional)
resource "aws_eip_association" "instance" {
  count = var.enable_elastic_ip ? 1 : 0
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.instance[0].id
}

# IAM role for EventBridge Scheduler to stop EC2 instances
resource "aws_iam_role" "scheduler_role" {
  name = "${var.system_name}-${var.environment}-scheduler-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.system_name}-${var.environment}-scheduler-role"
  }
}

# IAM policy for EventBridge Scheduler to stop EC2 instances
resource "aws_iam_policy" "scheduler_policy" {
  name        = "${var.system_name}-${var.environment}-scheduler-policy"
  description = "Policy for EventBridge Scheduler to stop EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.system_name}-${var.environment}-scheduler-policy"
  }
}

# Attach the policy to the scheduler role
resource "aws_iam_role_policy_attachment" "scheduler_policy_attachment" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

# EventBridge Scheduler to automatically stop the EC2 instance
resource "aws_scheduler_schedule" "stop_ec2_instance" {
  name       = "${var.system_name}-${var.environment}-stop-ec2-instance"
  group_name = "default"
  
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.auto_stop_cron_expression
  
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler_role.arn
    
    input = jsonencode({
      InstanceIds = [aws_instance.main.id]
    })
  }

  state = var.auto_stop_enabled ? "ENABLED" : "DISABLED"
}
