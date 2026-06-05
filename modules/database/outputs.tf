# 백엔드에 넘기기 위한 SQS URL
output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}
