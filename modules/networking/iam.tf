# ==================
# EKS 클러스터 Role
# ==================
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-eks-cluster-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ==================
# EKS 노드 Role
# ==================
resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-eks-node-role"

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
    Name        = "${var.project_name}-eks-node-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node.name
}

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
        "sqs:ReceiveMessage",    # ← Worker용 추가
        "sqs:DeleteMessage"      # ← Worker용 추가
      ]
      Resource = "*" #첫 배포시만 허용하고 나중에 특정 sqs arn으로 제한
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
# Secrets manager
# ==================

# Secrets Manager 접근 정책
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
# # Booking Pod: Aurora + SQS + ElastiCache
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
# # User Pod: Aurora만
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
# # Payment Pod: Aurora + SQS (ElastiCache 차단)
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
# ==================
resource "aws_iam_role" "cloudwatch" {
  name = "${var.project_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-cloudwatch-role"
    Environment = var.environment
  }
}

# CloudWatch 정책
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"
  role       = aws_iam_role.cloudwatch.name
}

# ==================
# CloudTrail Role
# ==================
resource "aws_iam_role" "cloudtrail" {
  name = "${var.project_name}-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-cloudtrail-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "${var.project_name}-cloudtrail-to-cloudwatch-policy"
  role = aws_iam_role.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}

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
      # CloudWatch 로그
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # SES 이메일 발송
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      # SQS 읽기
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      },
      # KMS 복호화
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.aurora.arn
      },
      # VPC 접근
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

# DMS가 RDS 접근하기 위해 추가
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

# DMS VPC 정책
resource "aws_iam_role_policy_attachment" "dms_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms.name
}

# DMS 로그 정책
resource "aws_iam_role_policy_attachment" "dms_logs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms.name
}