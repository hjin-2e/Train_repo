# ==============================================================================
# VPC Endpoints (VPC 엔드포인트) 구성
# ==============================================================================

# 1. S3 Gateway 엔드포인트 (시간당 비용 없음, 무료)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [
    aws_route_table.public.id,
    aws_route_table.private_a.id,
    aws_route_table.private_c.id,
    aws_route_table.db.id
  ]

  tags = {
    Name        = "${var.project_name}-s3-vpce"
    Environment = var.environment
  }
}

# Interface 엔드포인트용 전용 보안 그룹 (VPC 내부 통신용)
resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_vpc_endpoints ? 1 : 0
  name        = "${var.project_name}-vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-vpce-sg"
    Environment = var.environment
  }
}

# 2. SSM Interface 엔드포인트 (배스천 SSM 통신용)
resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ssm-vpce"
    Environment = var.environment
  }
}

# 3. SSMMessages Interface 엔드포인트 (배스천 SSM 채널용)
resource "aws_vpc_endpoint" "ssmmessages" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ssmmessages-vpce"
    Environment = var.environment
  }
}

# 4. EC2Messages Interface 엔드포인트 (인스턴스 메타데이터 통신용)
resource "aws_vpc_endpoint" "ec2messages" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ec2messages-vpce"
    Environment = var.environment
  }
}

# 5. ECR DKR Interface 엔드포인트 (EKS 파드 이미지 Pull용)
resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ecr-dkr-vpce"
    Environment = var.environment
  }
}

# 6. ECR API Interface 엔드포인트 (EKS 인증용)
resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.enable_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-ecr-api-vpce"
    Environment = var.environment
  }
}
