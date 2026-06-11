# ==================
# IRSA 공통 정책
# ==================

# Aurora 접근 정책
resource "aws_iam_policy" "aurora_access" {
  name = "${var.project_name}-aurora-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds-db:connect"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.aurora.arn
      }
    ]
  })
}

# SQS 접근 정책
resource "aws_iam_policy" "sqs_access" {
  name = "${var.project_name}-sqs-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ]
      Resource = "*" # 배포 후 특정 SQS ARN으로 제한 예정
    }]
  })
}

# ElastiCache 접근 정책
resource "aws_iam_policy" "elasticache_access" {
  name = "${var.project_name}-elasticache-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticache:DescribeCacheClusters",
        "elasticache:DescribeReplicationGroups"
      ]
      Resource = "*"
    }]
  })
}

# ==================
# Secrets Manager 접근 정책
# ==================
resource "aws_iam_policy" "secrets_access" {
  name = "${var.project_name}-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:ap-northeast-2:*:secret:${var.project_name}-db-secret*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.aurora.arn
      }
    ]
  })
}

# ==================
# Bastion SSM Role
# ==================
resource "aws_iam_role" "bastion_ssm" {
  name = "${var.project_name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-bastion-ssm-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_ssm.name
}

resource "aws_iam_instance_profile" "bastion_ssm" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion_ssm.name
}

# ==================
# IRSA - Booking Pod
# EKS 생성 후 주석 해제
# ==================
# resource "aws_iam_role" "booking_pod" {
#   name = "${var.project_name}-booking-pod-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = var.eks_oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format("%s:sub", var.eks_oidc_provider) = "system:serviceaccount:default:booking-sa"
#         }
#       }
#     }]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-booking-pod-role"
#     Environment = var.environment
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "booking_aurora" {
#   policy_arn = aws_iam_policy.aurora_access.arn
#   role       = aws_iam_role.booking_pod.name
# }
#
# resource "aws_iam_role_policy_attachment" "booking_sqs" {
#   policy_arn = aws_iam_policy.sqs_access.arn
#   role       = aws_iam_role.booking_pod.name
# }
#
# resource "aws_iam_role_policy_attachment" "booking_elasticache" {
#   policy_arn = aws_iam_policy.elasticache_access.arn
#   role       = aws_iam_role.booking_pod.name
# }
#
# resource "aws_iam_role_policy_attachment" "booking_secrets" {
#   policy_arn = aws_iam_policy.secrets_access.arn
#   role       = aws_iam_role.booking_pod.name
# }

# ==================
# IRSA - User Pod
# EKS 생성 후 주석 해제
# ==================
# resource "aws_iam_role" "user_pod" {
#   name = "${var.project_name}-user-pod-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = var.eks_oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format("%s:sub", var.eks_oidc_provider) = "system:serviceaccount:default:user-sa"
#         }
#       }
#     }]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-user-pod-role"
#     Environment = var.environment
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "user_aurora" {
#   policy_arn = aws_iam_policy.aurora_access.arn
#   role       = aws_iam_role.user_pod.name
# }

# ==================
# IRSA - Payment Pod
# EKS 생성 후 주석 해제
# ==================
# resource "aws_iam_role" "payment_pod" {
#   name = "${var.project_name}-payment-pod-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = var.eks_oidc_provider_arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format("%s:sub", var.eks_oidc_provider) = "system:serviceaccount:default:payment-sa"
#         }
#       }
#     }]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-payment-pod-role"
#     Environment = var.environment
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "payment_aurora" {
#   policy_arn = aws_iam_policy.aurora_access.arn
#   role       = aws_iam_role.payment_pod.name
# }
#
# resource "aws_iam_role_policy_attachment" "payment_sqs" {
#   policy_arn = aws_iam_policy.sqs_access.arn
#   role       = aws_iam_role.payment_pod.name
# }

# ==================
# CloudWatch Role
# [비용 절감] CloudWatch 연동 시 주석 해제
# ==================
# resource "aws_iam_role" "cloudwatch" {
#   name = "${var.project_name}-cloudwatch-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "cloudwatch.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-cloudwatch-role"
#     Environment = var.environment
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"
#   role       = aws_iam_role.cloudwatch.name
# }

# ==================
# CloudTrail Role
# [비용 절감] CloudWatch 연동 시 주석 해제
# ==================
# resource "aws_iam_role" "cloudtrail" {
#   name = "${var.project_name}-cloudtrail-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "cloudtrail.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-cloudtrail-role"
#     Environment = var.environment
#   }
# }
#
# resource "aws_iam_role_policy" "cloudtrail_policy" {
#   name = "${var.project_name}-cloudtrail-to-cloudwatch-policy"
#   role = aws_iam_role.cloudtrail.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ]
#       Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
#     }]
#   })
# }



# ==================
# Lambda Role
# ==================
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.aurora.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# ==================
# DMS Role
# ==================
# ==================
# DMS Roles
# AWS DMS가 자동으로 참조하는 고정 이름 역할 3개
# ==================

# 1. DMS VPC 관리 역할 (고정 이름 필수)
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "dms-vpc-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# 2. DMS CloudWatch 로그 역할 (고정 이름 필수)
resource "aws_iam_role" "dms_cloudwatch_role" {
  name = "dms-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "dms-cloudwatch-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_role_attachment" {
  role       = aws_iam_role.dms_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

# 3. DMS 엔드포인트 접근 역할 (고정 이름 필수)
resource "aws_iam_role" "dms_access_for_endpoint" {
  name = "dms-access-for-endpoint"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "dms-access-for-endpoint"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_attachment" {
  role       = aws_iam_role.dms_access_for_endpoint.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}

# 4. DMS RDS 접근 역할 (Aurora KMS 복호화 포함)
resource "aws_iam_role" "dms" {
  name = "${var.project_name}-dms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-dms-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "dms_rds_policy" {
  name = "${var.project_name}-dms-rds-policy"
  role = aws_iam_role.dms.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSubnetGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.aurora.arn
      }
    ]
  })
}