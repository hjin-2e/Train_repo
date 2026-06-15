data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions_backend" {
  name = "${var.project_name}-${var.environment}-github-actions-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-backend-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "github_actions_backend_ecr" {
  name = "${var.project_name}-${var.environment}-github-actions-backend-ecr-policy"
  role = aws_iam_role.github_actions_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRAuth"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "AllowECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          "arn:aws:ecr:*:*:repository/${var.project_name}-*-backend",
          "arn:aws:ecr:*:*:repository/${var.project_name}-*-worker"
        ]
      }
    ]
  })
}
