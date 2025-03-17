resource "aws_route53_zone" "private" {
  name = "${var.environment}.${var.domain_name}"
  
  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.system_name}-${var.environment}-private-zone"
  }
}
