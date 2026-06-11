# 알림용 SNS 토픽 생성
resource "aws_sns_topic" "alarm_topic" {
  name = "${var.project_name}-${var.environment}-alarm-topic"
}

# SNS 토픽에 이메일 구독자 지정
# 배포 후 해당 이메일로 구독 확인(Confirm Subscription) 메일이 오면 링크를 눌러 승인해야 합니다.
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# SQS 대기열 적체 경보 생성 (5분 동안 처리되지 않은 메시지가 100개 이상 쌓이면 발생)
resource "aws_cloudwatch_metric_alarm" "sqs_backlog_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-sqs-backlog-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "SQS 예약 큐에 메시지가 밀려 대기 중입니다. 백엔드/워커 상태를 확인하세요."

  dimensions = {
    QueueName = var.sqs_queue_name
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}