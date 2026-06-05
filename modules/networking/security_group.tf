# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
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

  # Bastion 접근 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow MySQL from Bastion"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-redis-sg"
    Environment = var.environment
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Bastion Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.developer_ips
    description = "Allow SSH from developer IPs only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}

# DMS Security Group
resource "aws_security_group" "dms" {
  name        = "${var.project_name}-dms-sg"
  description = "DMS Security Group for Azure Disaster Recovery Backup"
  vpc_id      = aws_vpc.main.id

  # DMS 내부 통신 허용 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow DMS internal communication"
  }

  # Aurora + Azure MySQL 아웃바운드
  # Azure DB IP 확정 후 수정 예정
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound to Aurora and Azure DR Database"
  }

  tags = {
    Name        = "${var.project_name}-dms-sg"
    Environment = var.environment
  }
}