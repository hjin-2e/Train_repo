# ==================
# VPC outputs
# ==================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}

output "db_subnet_ids" {
  description = "List of DB Subnet IDs"
  value = [
    aws_subnet.db_a.id,
    aws_subnet.db_c.id
  ]
}

# ==================
# NAT Gateway
# ==================
output "nat_gateway_public_ips" {
  description = "The public IP addresses of the NAT Gateways for external whitelist registration"
  value       = aws_eip.nat[*].public_ip
}

# ==================
# Security Group outputs
# ==================
output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb.id
}

output "eks_sg_id" {
  description = "Security Group ID for EKS"
  value       = aws_security_group.eks.id
}

output "aurora_sg_id" {
  description = "Security Group ID for Aurora DB"
  value       = aws_security_group.aurora.id
}

output "redis_sg_id" {
  description = "Security Group ID for Redis"
  value       = aws_security_group.redis.id
}

output "bastion_sg_id" {
  description = "Security Group ID for DB Bastion Server"
  value       = aws_security_group.db_bastion.id
}

output "eks_bastion_sg_id" {
  description = "Security Group ID for EKS Bastion Server"
  value       = aws_security_group.eks_bastion.id
}

output "bastion_ssm_role_arn" {
  description = "IAM Role ARN for Bastion SSM"
  value       = aws_iam_role.bastion_ssm.arn
}

output "dms_sg_id" {
  description = "Security Group ID for DMS"
  value       = aws_security_group.dms.id
}



# ==================
# ACM outputs
# ==================
output "acm_certificate_arn" {
  description = "ACM Certificate ARN for CloudFront"
  value       = var.environment == "prod" ? aws_acm_certificate.cloudfront[0].arn : ""
}

output "acm_alb_certificate_arn" {
  description = "ACM Certificate ARN for ALB"
  value       = var.environment == "prod" ? aws_acm_certificate.alb[0].arn : ""

}

# ==================
# CloudFront outputs
# ==================
output "s3_frontend_bucket" {
  description = "S3 Bucket name for frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "s3_frontend_bucket_regional_domain_name" {
  description = "S3 Bucket regional domain name for frontend"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "s3_frontend_bucket_arn" {
  description = "S3 Bucket ARN for frontend"
  value       = aws_s3_bucket.frontend.arn
}

# ==================
# WAF outputs
# ==================
output "waf_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

# ==================
# Bastion outputs
# ==================


output "bastion_instance_id" {
  description = "DB Bastion EC2 Instance ID (AZ-a)"
  value       = aws_instance.db_bastion.id
}

output "bastion_instance_id_c" {
  description = "DB Bastion EC2 Instance ID (AZ-c)"
  value       = aws_instance.db_bastion_c.id
}

output "eks_bastion_instance_id" {
  description = "EKS Bastion EC2 Instance ID (AZ-a)"
  value       = aws_instance.eks_bastion.id
}

output "eks_bastion_instance_id_c" {
  description = "EKS Bastion EC2 Instance ID (AZ-c)"
  value       = aws_instance.eks_bastion_c.id
}

output "eks_bastion_role_arn" {
  description = "IAM Role ARN of the EKS Bastion"
  value       = aws_iam_role.eks_bastion_ssm.arn
}

# ==================
# KMS outputs
# ==================
output "aurora_kms_key_arn" {
  description = "KMS Key ARN for Aurora DB Encryption"
  value       = aws_kms_key.aurora.arn
}

output "s3_kms_key_arn" {
  description = "KMS Key ARN for S3 Bucket Encryption"
  value       = aws_kms_key.s3.arn
}

output "redis_kms_key_arn" {
  description = "KMS Key ARN for ElastiCache Redis Encryption"
  value       = aws_kms_key.redis.arn
}

# ==================
# Component IAM Roles
# ==================
output "lambda_role_arn" {
  description = "IAM Role ARN for Lambda functions"
  value       = aws_iam_role.lambda.arn
}

# ==================
# CloudTrail outputs
# ==================
output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail configuration"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket" {
  description = "The name of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.arn
}

# ==================
# WAF Log Group
# ==================
output "waf_log_group_name" {
  description = "CloudWatch Log Group name for WAF logs (for Grafana integration)"
  value       = aws_cloudwatch_log_group.waf.name
}

# ==================
# Subnet Group outputs
# ==================
output "db_subnet_group_name" {
  description = "The name of the DB Subnet Group"
  value       = aws_db_subnet_group.aurora.name
}

output "redis_subnet_group_name" {
  description = "The name of the ElastiCache Redis Subnet Group"
  value       = aws_elasticache_subnet_group.redis.name
}

#  DMS 서브넷 그룹 아웃풋 
output "dms_replication_subnet_group_id" {
  description = "The ID of the DMS Replication Subnet Group"
  value       = aws_dms_replication_subnet_group.dms.replication_subnet_group_id
}

# ==================
# IAM Policies for IRSA
# ==================
output "aurora_policy_arn" {
  description = "IAM Policy ARN for Aurora DB access"
  value       = aws_iam_policy.aurora_access.arn
}

output "sqs_policy_arn" {
  description = "IAM Policy ARN for SQS access"
  value       = aws_iam_policy.sqs_access.arn
}

output "elasticache_policy_arn" {
  description = "IAM Policy ARN for ElastiCache access"
  value       = aws_iam_policy.elasticache_access.arn
}

output "secrets_policy_arn" {
  description = "IAM Policy ARN for Secrets Manager access"
  value       = aws_iam_policy.secrets_access.arn
}
