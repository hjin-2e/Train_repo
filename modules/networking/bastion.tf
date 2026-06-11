resource "aws_instance" "bastion" {
  ami                         = "ami-00e1a894b4512388e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  # iam.tf에서 생성한 profile 참조
  iam_instance_profile = aws_iam_instance_profile.bastion_ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y maria105
  EOF

  tags = {
    Name        = "${var.project_name}-bastion"
    Environment = var.environment
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-bastion-eip"
    Environment = var.environment
  }
}
