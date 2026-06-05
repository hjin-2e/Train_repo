# WAF는 CloudFront와 연동 시
# us-east-1 리전 필수

resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1
  name        = "${var.project_name}-waf"
  description = "train reservation project WAF"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # 규칙 1: AWS 관리형 기본 규칙
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # 규칙 2: SQL Injection 차단
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # 규칙 3: Rate Limiting (명절 봇 차단)
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000  # 5분간 2000회 초과 시 차단
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # 규칙 4: IP 차단 목록
  rule {
    name     = "IPBlockRule"
    priority = 4

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPBlockRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.project_name}-waf"
    Environment = var.environment
  }
}

# 차단할 IP 목록
resource "aws_wafv2_ip_set" "blocked" {
  provider           = aws.us_east_1
  name               = "${var.project_name}-blocked-ips"
  description        = "Blocked IP address list"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = []  # 차단할 IP 추가

  tags = {
    Name        = "${var.project_name}-blocked-ips"
    Environment = var.environment
  }
}