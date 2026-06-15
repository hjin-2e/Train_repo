# ==================
# IRSA 공통 정책
# ==================

# Aurora 접근 정책
# Resource를 프로젝트 클러스터로 한정 → 타 RDS 접근 차단
resource "aws_iam_policy" "aurora_access" {
  name = "${var.project_name}-aurora-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances"
        ]
        # 계정 내 이 프로젝트 클러스터만 허용 (cluster_identifier는 aurora_mysql.tf와 일치해야 함)
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster:${var.project_name}-aurora-cluster"
      },
      {
        Effect = "Allow"
        Action = ["rds-db:connect"]
        # IAM DB 인증 연결 대상도 동일 클러스터로 한정
        Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.project_name}-aurora-cluster/*"
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
# Resource를 프로젝트 큐 이름 패턴으로 한정 → 타 SQS 접근 차단
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
      # 이 프로젝트 SQS 큐만 허용 (team-train- 접두사 패턴)
      Resource = "arn:aws:sqs:ap-northeast-2:*:${var.project_name}-*"
    }]
  })
}

# ElastiCache 접근 정책
# Describe 작업은 리소스 레벨 권한 미지원 → * 유지 (AWS 제약)
# Action을 최소한으로 제한하는 것으로 보완
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
      Resource = "*" # ElastiCache Describe는 AWS 정책상 리소스 지정 불가
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
        # SM 시크릿은 AWS 기본 관리형 키 사용 → KMS 별도 권한 불필요
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-db-credentials*"
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




# ==============================================================================
# AWS DMS Default Service Roles (Required once per AWS Account)
# ==============================================================================

# 1. dms-vpc-role
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
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# 2. dms-cloudwatch-role
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
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_role_attachment" {
  role       = aws_iam_role.dms_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

# 3. dms-access-for-endpoint
# 롤 이름은 AWS DMS가 자동으로 탐색하는 계정 레벨 서비스 롤이므로 유지
# AmazonDMSRedshiftS3Role은 Redshift/S3 endpoint 전용이므로 미첨부 (Aurora→Azure MySQL 구성에 불필요)
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
}

# ==============================================================================
# 4. EKS Bastion SSM Role
# ==============================================================================
resource "aws_iam_role" "eks_bastion_ssm" {
  name = "${var.project_name}-${var.environment}-eks-bastion-role"

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
    Name        = "${var.project_name}-${var.environment}-eks-bastion-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_bastion_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_bastion_ssm.name
}

# aws eks update-kubeconfig 실행에 필요한 최소 권한
resource "aws_iam_role_policy" "eks_bastion_describe" {
  name = "${var.project_name}-${var.environment}-eks-bastion-describe"
  role = aws_iam_role.eks_bastion_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["eks:DescribeCluster"]
      Resource = "arn:aws:eks:ap-northeast-2:*:cluster/${var.project_name}-${var.environment}-eks"
    }]
  })
}

resource "aws_iam_instance_profile" "eks_bastion_ssm" {
  name = "${var.project_name}-${var.environment}-eks-bastion-profile"
  role = aws_iam_role.eks_bastion_ssm.name
}
