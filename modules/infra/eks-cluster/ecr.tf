# ECR 리포지토리를 구성
# Front는 S3에 있어서 엄밀히 따지면 필요없긴 함.

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}