# ==============================================================================
# ACM 인증서 및 DNS 검증 리소스
# (cloudfront.tf 및 output.tf의 직접 참조 유지를 위해 networking 모듈 내부에 보존)
# ==============================================================================

# Route53 퍼블릭 호스팅 영역 참조
data "aws_route53_zone" "primary" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "team-train.cloud"
  private_zone = false
}

# 1. CloudFront용 ACM 인증서 (us-east-1 리전 필수)
resource "aws_acm_certificate" "main" {
  count             = var.environment == "prod" ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = "team-train.cloud"
  validation_method = "DNS"

  subject_alternative_names = ["*.team-train.cloud"]

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront ACM DNS 검증 레코드
resource "aws_route53_record" "acm_validation_main" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
  allow_overwrite = true
}

# CloudFront ACM 검증 완료 대기
resource "aws_acm_certificate_validation" "main" {
  count                   = var.environment == "prod" ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [aws_route53_record.acm_validation_main[0].fqdn]
}

# 2. ALB용 ACM 인증서 (서울 리전)
resource "aws_acm_certificate" "alb" {
  count             = var.environment == "prod" ? 1 : 0
  domain_name       = "api.team-train.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ALB ACM DNS 검증 레코드
resource "aws_route53_record" "acm_validation_alb" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
  allow_overwrite = true
}

# ALB ACM 검증 완료 대기
resource "aws_acm_certificate_validation" "alb" {
  count                   = var.environment == "prod" ? 1 : 0
  certificate_arn         = aws_acm_certificate.alb[0].arn
  validation_record_fqdns = [aws_route53_record.acm_validation_alb[0].fqdn]
}
