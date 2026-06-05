output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "eks_sg_id" {
  value = aws_security_group.eks.id
}

output "aurora_sg_id" {
  value = aws_security_group.aurora.id
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "route53_nameservers" {
  description = "domain name server"
  value       = aws_route53_zone.main.name_servers
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.main.arn
}

output "acm_alb_certificate_arn" {
  value = aws_acm_certificate.alb.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

output "s3_frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "waf_arn" {
  value = aws_wafv2_web_acl.main.arn
}


output "bastion_public_ip" {
  description = "Bastion Server Public IP"
  value       = aws_eip.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Bastion Instance ID"
  value       = aws_instance.bastion.id
}