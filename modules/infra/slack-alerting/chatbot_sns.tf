# ==============================================================================
# DB Audit Logs 알림 (SNS + CloudWatch Alarm)
# ==============================================================================

# 1. SNS 토픽 생성 (AWS Chatbot이 이 토픽을 구독하게 됩니다)
resource "aws_sns_topic" "db_audit_alerts" {
  name = "${var.project_name}-${var.environment}-db-audit-alerts"
}

# 2. CloudWatch Log Group 이름 (Aurora Audit 로그 그룹)
# Aurora MySQL의 감사 로그는 일반적으로 /aws/rds/cluster/<cluster_name>/audit 에 저장됩니다.
locals {
  aurora_audit_log_group = "/aws/rds/cluster/${var.project_name}-aurora-cluster/audit"
}

# 3. CloudWatch Metric Filter (위험한 쿼리 감지)
resource "aws_cloudwatch_log_metric_filter" "db_drop_table" {
  name           = "${var.project_name}-${var.environment}-db-drop-table-filter"
  log_group_name = local.aurora_audit_log_group

  # 감사 로그 내에서 DROP, DELETE, TRUNCATE 단어를 감지합니다.
  pattern = "?\"DROP TABLE\" ?\"DELETE FROM\" ?\"TRUNCATE TABLE\""

  metric_transformation {
    name          = "DangerousQueryCount"
    namespace     = "${var.project_name}/${var.environment}/Database"
    value         = "1"
    default_value = "0"
  }
}

# 4. CloudWatch Alarm (알람 조건)
resource "aws_cloudwatch_metric_alarm" "db_danger_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-db-danger-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.db_drop_table.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.db_drop_table.metric_transformation[0].namespace
  period              = "60" # 1분 동안
  statistic           = "Sum"
  threshold           = "1" # 1회 이상 발생 시
  alarm_description   = "DB에서 테이블 DROP/DELETE/TRUNCATE 와 같은 위험한 쿼리가 감지되었습니다!"

  # 알람 발생 시 위에서 만든 SNS 토픽으로 메시지 전송
  alarm_actions = [aws_sns_topic.db_audit_alerts.arn]
  ok_actions    = [aws_sns_topic.db_audit_alerts.arn]
}
