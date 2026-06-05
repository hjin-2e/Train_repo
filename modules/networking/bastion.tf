# SSH 키 페어
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
  ami                         = "ami-0c9c942bd7bf113a2"
  instance_type               = "t2.micro"

  # 변수 대신 직접 참조 
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y mysql
  EOF

  tags = {
    Name        = "${var.project_name}-bastion"
    Environment = var.environment
  }
}

# Bastion EIP
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-bastion-eip"
    Environment = var.environment
  }
}