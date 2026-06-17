# CloudFront Managed Prefix List 참조
# AWS가 관리하는 CloudFront 엣지 노드 IP 목록 (자동 업데이트)
# 이 목록 이외의 IP는 ALB에 직접 접근 불가 → WAF 우회 차단
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB Security Group - CloudFront only"
  vpc_id      = aws_vpc.main.id

  # CloudFront 엣지 노드에서 오는 HTTPS만 허용 (HTTP -> HTTPS 리다이렉트는 CloudFront에서 처리)

  # 환경별 CloudFront 통신 허용: prod는 443(HTTPS), dev는 80(HTTP)
  # 0.0.0.0/0 외부 직접 접근 차단 → WAF 우회 불가
  dynamic "ingress" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
      description     = "Allow HTTPS from CloudFront for prod"
    }
  }

  dynamic "ingress" {
    for_each = var.environment != "prod" ? [1] : []
    content {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
      description     = "Allow HTTP from CloudFront for dev"
    }
  }

  # 내부망 접근 허용: dev 환경에서만 베스천/NAT GW 테스트 허용
  # prod에서는 CloudFront prefix list만 허용 → WAF 우회 차단 유지
  dynamic "ingress" {
    for_each = var.environment != "prod" ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.main.cidr_block]
      description = "Allow HTTP from VPC internal (Bastion, etc) - dev only"
    }
  }

  dynamic "ingress" {
    for_each = var.environment != "prod" ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = formatlist("%s/32", aws_eip.nat[*].public_ip)
      description = "Allow HTTP from NAT Gateway (for Bastion testing) - dev only"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound to EKS"
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
  }
}

# EKS Security Group
resource "aws_security_group" "eks" {
  name        = "${var.project_name}-eks-sg"
  description = "EKS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow all inbound from ALB"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow internal EKS communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-eks-sg"
    Environment = var.environment
  }
}

# Aurora Security Group
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Aurora Security Group"
  vpc_id      = aws_vpc.main.id

  # EKS 접근 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
    description     = "Allow MySQL from EKS"
  }

  # DB Bastion 접근 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db_bastion.id]
    description     = "Allow MySQL from DB Bastion"
  }

  # DMS 접근 허용 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dms.id]
    description     = "Allow MySQL from DMS"
  }

  # VPC 내부로만 아웃바운드 제한 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow outbound within VPC only"
  }

  tags = {
    Name        = "${var.project_name}-aurora-sg"
    Environment = var.environment
  }
}

# Redis Security Group
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Redis Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
    description     = "Allow Redis from EKS"
  }

  # DB Bastion 접근 허용 (테스트용 임시 규칙)
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.db_bastion.id]
    description     = "Allow Redis from DB Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow outbound within VPC only"
  }

  tags = {
    Name        = "${var.project_name}-redis-sg"
    Environment = var.environment
  }
}

# DB Bastion Security Group
resource "aws_security_group" "db_bastion" {
  name_prefix = "${var.project_name}-db-bastion-sg-"
  description = "DB Bastion Security Group (SSM only, no SSH)"
  vpc_id      = aws_vpc.main.id

  # SSM Agent 및 일반 HTTP/HTTPS 통신
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for SSM Agent and internet"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound for API testing"
  }

  # Bastion → Aurora DB 접근 (점프 서버 용도)
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow MySQL outbound to Aurora in VPC"
  }

  tags = {
    Name        = "${var.project_name}-db-bastion-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Bastion Security Group
resource "aws_security_group" "eks_bastion" {
  name_prefix = "${var.project_name}-eks-bastion-sg-"
  description = "EKS Bastion Security Group (SSM only, no Inbound)"
  vpc_id      = aws_vpc.main.id

  # SSM Agent and EKS API Server → HTTPS outbound
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for SSM Agent and EKS API"
  }

  tags = {
    Name        = "${var.project_name}-eks-bastion-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DMS Security Group
resource "aws_security_group" "dms" {
  name        = "${var.project_name}-dms-sg"
  description = "DMS Security Group for Azure Disaster Recovery Backup"
  vpc_id      = aws_vpc.main.id

  # DMS 내부 통신 허용 (multi-AZ standby 간 통신)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow DMS internal communication"
  }

  # Aurora 아웃바운드 (Aurora가 위치한 db 서브넷만 허용 - 최소권한)
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.db_a.cidr_block, aws_subnet.db_c.cidr_block]
    description = "Allow outbound to Aurora (DB subnet only)"
  }

  # DMS multi-AZ 인스턴스 간 내부 통신 (private 서브넷 대역)
  # DMS Replication Instance가 private_a/c에 배치되므로
  # Standby 인스턴스와의 하트비트/동기화를 위해 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private_a.cidr_block, aws_subnet.private_c.cidr_block]
    description = "Allow DMS multi-AZ internal communication (private subnets)"
  }

  # Azure MySQL 아웃바욤드: S2S VPN 터널을 통한 사설 통신만 허용 (공개 인터넷 차단)
  # 라우팅: DMS(private 서브넷) → VGW → S2S VPN 터널 → Azure VNet → MySQL(10.1.2.x)
  dynamic "egress" {
    for_each = var.azure_vnet_cidr != "" ? [1] : []
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.azure_vnet_cidr]
      description = "Allow outbound to Azure MySQL via S2S VPN (private tunnel only)"
    }
  }

  tags = {
    Name        = "${var.project_name}-dms-sg"
    Environment = var.environment
  }
}