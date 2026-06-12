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
  description = "Security Group ID for Bastion Server"
  value       = aws_security_group.bastion.id
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
output "cloudfront_domain_name" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "s3_frontend_bucket" {
  description = "S3 Bucket name for frontend"
  value       = aws_s3_bucket.frontend.bucket
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
# output "bastion_public_ip" {
#   description = "Bastion Server Public IP Address"
#   value       = aws_eip.bastion.public_ip
# }

output "bastion_instance_id" {
  description = "Bastion EC2 Instance ID"
  value       = aws_instance.bastion.id
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
# IRSA Pod Roles
# ==================
# output "booking_pod_role_arn" {
#   description = "IAM Role ARN for the Booking Service Pod"
#   value       = aws_iam_role.booking_pod.arn
# }
# 
# output "user_pod_role_arn" {
#   description = "IAM Role ARN for the User Service Pod"
#   value       = aws_iam_role.user_pod.arn
# }
# 
# output "payment_pod_role_arn" {
#   description = "IAM Role ARN for the Payment Service Pod"
#   value       = aws_iam_role.payment_pod.arn
# }


# ==================
# Secrets Manager
# ==================

# output "db_secret_arn" {
#   description = "ARN of the DB Secrets Manager secret"
#   value       = aws_secretsmanager_secret.db.arn
# }


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
# Component IAM Roles
# [비용 절감] CloudWatch 연동 시 주석 해제
# ==================
# output "cloudwatch_role_arn" {
#   description = "IAM Role ARN for CloudWatch Logging"
#   value       = aws_iam_role.cloudwatch.arn
# }
#
# output "cloudtrail_role_arn" {
#   description = "IAM Role ARN for CloudTrail"
#   value       = aws_iam_role.cloudtrail.arn
# }

# ==================
# CloudTrail Log Group outputs
# [비용 절감] CloudWatch 연동 시 주석 해제
# ==================
# output "cloudtrail_log_group" {
#   description = "The name of the CloudWatch Log Group for CloudTrail"
#   value       = aws_cloudwatch_log_group.cloudtrail.name
# }
#
# output "cloudtrail_log_group_arn" {
#   description = "The ARN of the CloudWatch Log Group for CloudTrail"
#   value       = aws_cloudwatch_log_group.cloudtrail.arn
# }



# ==================
# WAF Log Group
# ==================
output "waf_log_group_name" {
  description = "CloudWatch Log Group name for WAF logs (for Grafana integration)"
  value       = aws_cloudwatch_log_group.waf.name
}



# ==================
# EKS Addon outputs
# ==================
# output "vpc_cni_addon" {
#   description = "The name of the VPC CNI EKS addon" 
#   value       = aws_eks_addon.vpc_cni.addon_name
# }

# # ==================
# # RBAC outputs
# # ==================
# output "developer_role_name" {
#   description = "The name of the developer ClusterRole" 
#   value       = kubernetes_cluster_role.developer.metadata[0].name
# }

# # ==================
# # Service Account outputs
# # ==================
# output "booking_sa_name" {
#   description = "The name of the Service Account for Booking service" 
#   value       = kubernetes_service_account.booking.metadata[0].name
# }

# output "user_sa_name" {
#   description = "The name of the Service Account for User service" 
#   value       = kubernetes_service_account.user.metadata[0].name
# }

# output "payment_sa_name" {
#   description = "The name of the Service Account for Payment service" 
#   value       = kubernetes_service_account.payment.metadata[0].name
# }

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


