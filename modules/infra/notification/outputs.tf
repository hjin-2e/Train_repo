# Lambda 함수 ARN (CloudWatch 로그 확인, 수동 테스트 호출 시 사용)
output "lambda_function_arn" {
  description = "Alarm Lambda function ARN"
  value       = aws_lambda_function.notification_lambda.arn
}

# SNS 토픽 ARN (CloudWatch 알람이 연결된 토픽, 추가 구독 등록 시 사용)
output "sns_topic_arn" {
  description = "CloudWatch Alarm receiving SNS topic ARN"
  value       = aws_sns_topic.alarm_topic.arn
}

# SES 발신자 이메일 (인증 상태 확인용)
output "ses_sender_email" {
  description = "SES sender email"
  value       = aws_ses_email_identity.sender.email
}
