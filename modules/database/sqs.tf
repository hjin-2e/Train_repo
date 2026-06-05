# SQS Standard 큐 생성
resource "aws_sqs_queue" "queue" {
  name = "reservation-queue"

  # 메시지 보존 기간
  message_retention_seconds = 345600

  # 가시성 제한 시간
  visibility_timeout_seconds = 30

  # 롱 폴링
  receive_wait_time_seconds = 20

  tags = {
    Name = "trail-reservation-queue"
  }
}
