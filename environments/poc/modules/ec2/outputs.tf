output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.enable_elastic_ip ? aws_eip.instance[0].public_ip : aws_instance.main.public_ip
}
