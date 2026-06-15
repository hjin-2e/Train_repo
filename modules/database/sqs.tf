# SQS Standard 큐 생성
resource "aws_sqs_queue" "queue" {
  name = "reservation-queue"

  # 메시지 보존 기간
  message_retention_seconds = 345600
  # 가시성 제한 시간
  visibility_timeout_seconds = 30
  # 롱 폴링
  receive_wait_time_seconds = 20

  # SSE-SQS 암호화 활성화
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_dlq.arn
    maxReceiveCount     = 3 # 3회 처리 실패 시 DLQ로 격리
  })

  tags = {
    Name = "trail-reservation-queue"
  }
}

# 🚨 데드 레터 큐 (DLQ) 생성
resource "aws_sqs_queue" "queue_dlq" {
  name                       = "reservation-queue-dlq"
  message_retention_seconds  = 1209600 # 격리된 메시지 분석을 위해 보존 기간을 길게 설정 (14일)
  visibility_timeout_seconds = 30

  # SSE-SQS 암호화 활성화
  sqs_managed_sse_enabled = true

  tags = { Name = "trail-reservation-queue-dlq" }
}

# SES 용 SQS 큐 생성
resource "aws_sqs_queue" "mail_queue" {
  name = "mail-queue"

  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 20

  # SSE-SQS 암호화 활성화
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.mail_queue_dlq.arn
    maxReceiveCount     = 3 # 3회 처리 실패 시 DLQ로 격리
  })

  tags = {
    Name = "trail-mail-queue"
  }
}

# SES용 데드 레터 큐 (DLQ) 생성
resource "aws_sqs_queue" "mail_queue_dlq" {
  name                       = "mail-queue-dlq"
  message_retention_seconds  = 1209600 # 14일
  visibility_timeout_seconds = 30

  # SSE-SQS 암호화 활성화
  sqs_managed_sse_enabled = true

  tags = { Name = "trail-mail-queue-dlq" }
}

