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

  # SSM Agent → AWS 엔드포인트 통신
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for SSM Agent"
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