# Route53 호스팅 존
resource "aws_route53_zone" "main" {
  name = "team-train.cloud"

  tags = {
    Name        = "${var.project_name}-zone"
    Environment = var.environment
  }
}

# 메인 도메인 → CloudFront
# resource "aws_route53_record" "main" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "team-train.cloud"
#   type    = "A"

#   alias {
#     name                   = var.cloudfront_domain_name
#     zone_id                = var.cloudfront_zone_id
#     evaluate_target_health = false
#   }
# }

# # api 서브도메인 → ALB
# resource "aws_route53_record" "api" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "api.team-train.cloud"
#   type    = "A"

#   alias {
#     name                   = var.alb_dns_name
#     zone_id                = var.alb_zone_id
#     evaluate_target_health = true
#   }
# }

# DB 장애 전환용 레코드
# resource "aws_route53_record" "db" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "db.team-train.cloud"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [var.aurora_endpoint]
# }

# CloudFront ACM 인증서 검증 레코드 
resource "aws_route53_record" "acm_validation_main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ALB ACM 인증서 검증 레코드 추가
resource "aws_route53_record" "acm_validation_alb" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}