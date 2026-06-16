# Cognito User Pool
resource "aws_cognito_user_pool" "pool" {
  name = "${var.project_name}-${var.environment}-user-pool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-user-pool"
    Environment = var.environment
  }
}

# Cognito Client (Cognito에 접근하기 위한 키값)
resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.project_name}-${var.environment}-app-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH", # ID/PW 방식 인증 허용
    "ALLOW_REFRESH_TOKEN_AUTH", # 토큰 갱신 허용
    "ALLOW_USER_SRP_AUTH"       # 보안 강화 SRP 인증 방식 허용
  ]

  # 로그인 계정 존재 여부 방어
  prevent_user_existence_errors = "ENABLED"
}

# Cognito 로그인 UI 및 인증 엔드포인트 도메인
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}-auth-platform"
  user_pool_id = aws_cognito_user_pool.pool.id
}