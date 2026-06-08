# 백엔드 JWT 검증 시 사용
output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.pool.id
}

# 로그인 시 사용
output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.client.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.pool.arn
}

output "cognito_domain" {
  description = "Cognito Domain Name"
  value       = aws_cognito_user_pool_domain.main.domain
}