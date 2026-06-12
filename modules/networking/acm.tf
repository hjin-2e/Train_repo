# ==============================================================================
# ACM (AWS Certificate Manager) 인증서
#
# CloudFront와 ALB는 각각 다른 리전의 인증서를 요구합니다.
#   - CloudFront : 전역 서비스이므로 반드시 us-east-1 인증서 사용
#   - ALB        : 리전 서비스이므로 ap-northeast-2 인증서 사용
#
# 두 인증서 모두 prod 환경에서만 생성합니다.
# dev 환경은 CloudFront 기본 인증서를 사용하므로 ACM 불필요.
# ==============================================================================

# Route53 호스팅 존 조회 (DNS 검증 레코드 등록용)
# domain 모듈에서 생성한 team-train.cloud 존을 데이터 소스로 참조
data "aws_route53_zone" "main" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "team-train.cloud"
  private_zone = false
}

# ==============================================================================
# 1. CloudFront 인증서 (us-east-1)
# ==============================================================================
resource "aws_acm_certificate" "cloudfront" {
  count    = var.environment == "prod" ? 1 : 0
  provider = aws.us_east_1

  domain_name               = "team-train.cloud"
  subject_alternative_names = ["www.team-train.cloud"]
  validation_method         = "DNS"

  tags = {
    Name        = "${var.project_name}-cf-cert"
    Environment = var.environment
  }

  # 인증서 갱신 시 기존 인증서를 먼저 교체 후 삭제 (CloudFront 연결 끊김 방지)
  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront 인증서 DNS 검증 레코드 Route53에 자동 등록
# for_each로 domain_validation_options를 순회하여 검증 레코드를 생성
resource "aws_route53_record" "cert_validation_cloudfront" {
  for_each = var.environment == "prod" ? {
    for dvo in aws_acm_certificate.cloudfront[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# DNS 검증 레코드가 전파될 때까지 대기 (cloudfront.tf의 depends_on 대상)
resource "aws_acm_certificate_validation" "cloudfront" {
  count    = var.environment == "prod" ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_cloudfront : record.fqdn]
}

# ==============================================================================
# 2. ALB 인증서 (ap-northeast-2)
# ==============================================================================
resource "aws_acm_certificate" "alb" {
  count = var.environment == "prod" ? 1 : 0

  domain_name       = "api.team-train.cloud"
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-alb-cert"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ALB 인증서 DNS 검증 레코드 Route53에 자동 등록
resource "aws_route53_record" "cert_validation_alb" {
  for_each = var.environment == "prod" ? {
    for dvo in aws_acm_certificate.alb[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ALB 인증서 검증 완료 대기
resource "aws_acm_certificate_validation" "alb" {
  count = var.environment == "prod" ? 1 : 0

  certificate_arn         = aws_acm_certificate.alb[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_alb : record.fqdn]
}
