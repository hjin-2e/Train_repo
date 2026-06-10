
# data 소스로 참조
data "aws_route53_zone" "primary" {
  count = var.environment == "prod" ? 1 : 0
  name  = "team-train.cloud"
}

# ACM 인증서 (prod만)
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

# ACM 검증 레코드 (prod만)
resource "aws_route53_record" "acm_validation_main" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.main[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
  allow_overwrite = true
}

# ACM 검증 완료 대기 (prod만)
resource "aws_acm_certificate_validation" "main" {
  count                   = var.environment == "prod" ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [aws_route53_record.acm_validation_main[0].fqdn]
}

# ALB ACM (prod만)
resource "aws_acm_certificate" "alb" {
  count             = var.environment == "prod" ? 1 : 0
  domain_name       = "api.team-train.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 메인 도메인 레코드 (prod만)
resource "aws_route53_record" "main" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "team-train.cloud"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# API 레코드 (prod만)
resource "aws_route53_record" "api" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "api.team-train.cloud"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# ALB ACM 검증 레코드 추가 
resource "aws_route53_record" "acm_validation_alb" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.alb[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "alb" {
  count                   = var.environment == "prod" ? 1 : 0
  certificate_arn         = aws_acm_certificate.alb[0].arn
  validation_record_fqdns = [aws_route53_record.acm_validation_alb[0].fqdn]
}

# DB 레코드는 prod + aurora 완성 후
# 이중 조건 필요

resource "aws_route53_record" "db" {
  count   = var.environment == "prod" && var.aurora_endpoint != "" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "db.team-train.cloud"
  type    = "CNAME"
  ttl     = "60"
  records = [var.aurora_endpoint]
}


















