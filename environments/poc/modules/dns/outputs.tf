output "zone_id" {
  description = "ID of the Route 53 private zone"
  value       = aws_route53_zone.private.zone_id
}

output "zone_name" {
  description = "Name of the Route 53 private zone"
  value       = aws_route53_zone.private.name
}

output "domain_name" {
  description = "Full domain name for the private zone"
  value       = aws_route53_zone.private.name
}
