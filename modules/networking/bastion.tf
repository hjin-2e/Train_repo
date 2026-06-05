# SSH 키 페어 생성
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = file(var.bastion_public_key_path)

  tags = {
    Name        = "${var.project_name}-bastion-key"
    Environment = var.environment
  }
}

# Bastion Server EC2
resource "aws_instance" "bastion" {
  ami                    = "ami-0aef7d1237f8a3805"  # Amazon Linux 2023 (서울)
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_ids[0] # Public Subnet AZ-a
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [var.bastion_sg_id]

  # 퍼블릭 IP 자동 할당
  associate_public_ip_address = false

  # 기본 설정 스크립트
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y mariadb105  # Aurora 접속용 MySQL 클라이언트
  EOF

  tags = {
    Name        = "${var.project_name}-bastion"
    Environment = var.environment
  }
}

# Bastion EIP (고정 IP)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-bastion-eip"
    Environment = var.environment
  }
}