# ==============================================================================
# DB Bastion Instance (SSM-only, private subnet)
# ==============================================================================
resource "aws_instance" "db_bastion" {
  ami                         = "ami-00e1a894b4512388e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.db_bastion.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.bastion_ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y mariadb105
  EOF

  tags = {
    Name        = "${var.project_name}-db-bastion"
    Environment = var.environment
  }
}

# ==============================================================================
# EKS Bastion Instance (SSM-only, private subnet, with kubectl & helm)
# ==============================================================================
resource "aws_instance" "eks_bastion" {
  ami                         = "ami-00e1a894b4512388e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.eks_bastion.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.eks_bastion_ssm.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    # kubectl 1.30.0 설치
    curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/
    # helm 설치
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
  EOF

  tags = {
    Name        = "${var.project_name}-eks-bastion"
    Environment = var.environment
  }
}
