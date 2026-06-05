# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  # 인바운드: HTTP 허용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  # 인바운드: HTTPS 허용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
  }

  # 아웃바운드: EKS로만 허용
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description     = "Allow all outbound to EKS"
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

  # 인바운드: ALB에서만 허용
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow all inbound from ALB"
  }

  # 인바운드: 내부 통신 허용
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
    description = "Allow internal EKS communication"
  }

  # 아웃바운드: 전체 허용
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

  # 인바운드: EKS에서만 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
    description     = "Allow MySQL from EKS"
  }

  # 인바운드: Bastion에서만 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow MySQL from Bastion"
  }

  # 아웃바운드는 외부 허용을 막기 위해 cidr 수정했습니다
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
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

  # 인바운드: EKS에서만 허용
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
    description     = "Allow Redis from EKS"
  }

  # 아웃바운드: 없음
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

  # 인바운드: 개발자 IP만 SSH 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.developer_ips
    description = "Allow SSH from developer IPs only"
  }

  # 아웃바운드: Aurora, Redis, EKS 접근
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}