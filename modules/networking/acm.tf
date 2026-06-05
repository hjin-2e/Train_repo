# CloudFront용 인증서 (us-east-1 필수)
resource "aws_acm_certificate" "main" {
  provider          = aws.us_east_1
  domain_name       = "teamkorail.cloud"
  validation_method = "DNS"

  subject_alternative_names = [
    "*.teamkorail.cloud"
  ]

  tags = {
    Name        = "${var.project_name}-cert"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 인증서 검증 완료 대기
resource "aws_acm_certificate_validation" "main" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.acm_validation : record.fqdn
  ]
}

# ALB용 인증서 (ap-northeast-2)
resource "aws_acm_certificate" "alb" {
  domain_name       = "api.teamkorail.cloud"
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-alb-cert"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}