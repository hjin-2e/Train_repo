resource "aws_instance" "bastion" {
  ami                         = "ami-00e1a894b4512388e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = false

  # iam.tf에서 생성한 profile 참조
  iam_instance_profile = aws_iam_instance_profile.bastion_ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y mariadb105
  EOF

  tags = {
    Name        = "${var.project_name}-bastion"
    Environment = var.environment
  }
}
