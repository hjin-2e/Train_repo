output "zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "nameservers" {
  description = "Route53 Nameservers for Gabia"
  value       = aws_route53_zone.main.name_servers
}

output "zone_name" {
  description = "Route53 Hosted Zone Name"
  value       = aws_route53_zone.main.name
}