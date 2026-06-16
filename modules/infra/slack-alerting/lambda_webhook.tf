# ==============================================================================
# App Error Logs 알림 (Lambda + Slack Webhook)
# ==============================================================================

# 1. Lambda IAM Role
resource "aws_iam_role" "slack_lambda_role" {
  name = "${var.project_name}-${var.environment}-slack-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Lambda 기초 실행 권한 (CloudWatch Logs 기록 권한 등)
resource "aws_iam_role_policy_attachment" "slack_lambda_basic" {
  role       = aws_iam_role.slack_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 2. Lambda 소스 코드 압축
data "archive_file" "slack_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/slack_lambda_function.zip"
}

# 3. AWS Lambda Function
resource "aws_lambda_function" "slack_notifier" {
  filename         = data.archive_file.slack_lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-slack-notifier"
  role             = aws_iam_role.slack_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.slack_lambda_zip.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      ENVIRONMENT       = var.environment
    }
  }
}

# 4. CloudWatch Logs 권한 허용 (Subscription Filter가 Lambda를 호출할 수 있도록)
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "logs.${var.aws_region}.amazonaws.com"

  # 특정 로그 그룹에서만 호출 가능하도록 제한 (EKS 컨테이너 로그 그룹)
  source_arn = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/eks/${var.project_name}-${var.environment}-eks/containers:*"
}

data "aws_caller_identity" "current" {}

# 5. CloudWatch Subscription Filter (EKS 컨테이너 로그 그룹)
resource "aws_cloudwatch_log_subscription_filter" "app_error_filter" {
  name           = "${var.project_name}-${var.environment}-app-error-filter"
  log_group_name = "/eks/${var.project_name}-${var.environment}-eks/containers"

  # "ERROR" 또는 "Exception" 단어가 들어간 로그를 필터링
  filter_pattern  = "?ERROR ?Exception ?\"Failed to refresh slots cache\""
  destination_arn = aws_lambda_function.slack_notifier.arn

  depends_on = [aws_lambda_permission.allow_cloudwatch]
}
