output "github_actions_backend_role_arn" {
  description = "Backend CI/CD 템플릿의 role-to-assume 값으로 사용하세요."
  value       = aws_iam_role.github_actions_backend.arn
}
