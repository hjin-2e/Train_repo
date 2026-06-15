# 현재 AWS 계정 ID 정보 가져오기
data "aws_caller_identity" "current" {}

# Lambda 기본 실행 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# SQS 읽기 및 CloudWatch 로깅 권한을 갖는 AWS 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "lambda_sqs_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# (옵션) Lambda가 SES를 통해 메일을 보낼 수 있는 권한 추가
resource "aws_iam_role_policy" "lambda_ses_policy" {
  name = "${var.project_name}-${var.environment}-lambda-ses-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = "*"
    }]
  })
}

# Lambda 소스 코드 압축 (모듈 폴더 내부에 'lambda_code' 폴더를 만들고 index.js를 넣어두세요)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda 함수 생성
resource "aws_lambda_function" "notification_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-${var.environment}-notification-service"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SES_REGION   = var.aws_region
      SENDER_EMAIL = var.verified_email_or_domain
    }
  }
}

# SQS -> Lambda 이벤트 트리거 정의
# 메일 발송용 SQS 큐(mail-queue)에 메시지가 적재되면 알림 Lambda가 SES를 통해 이메일을 발송합니다.
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.notification_lambda.arn
  batch_size       = 10
  enabled          = true
}
