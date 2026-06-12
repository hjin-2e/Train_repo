# ==============================================================================
# Production 전용 최종 Route53 DNS 도메인 연결 레코드
# (모듈 간 순환 의존성 해결을 위해 최상위 루트 레벨로 관리)
# ==============================================================================

# Route53 퍼블릭 호스팅 영역 참조
data "aws_route53_zone" "primary" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "team-train.cloud"
  private_zone = false
}

# 1. 루트 도메인 레코드 (CloudFront 타겟팅 - 자동화)
resource "aws_route53_record" "main" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "team-train.cloud"
  type    = "A"

  alias {
    name                   = module.networking.cloudfront_domain_name  # 🔴 networking 모듈의 CloudFront 아웃풋 참조
    zone_id                = "Z2FDTNDATAQYW2"                          # CloudFront 전역 고정 Zone ID
    evaluate_target_health = false
  }
}

# www 도메인 레코드 (CloudFront 타겟팅 - 자동화)
resource "aws_route53_record" "www" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "www.team-train.cloud"
  type    = "A"

  alias {
    name                   = module.networking.cloudfront_domain_name  # 🔴 networking 모듈의 CloudFront 아웃풋 참조
    zone_id                = "Z2FDTNDATAQYW2"                          # CloudFront 전역 고정 Zone ID
    evaluate_target_health = false
  }
}

# 2. API 서브 도메인 레코드 (ALB 타겟팅 - 자동화)
resource "aws_route53_record" "api" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "api.team-train.cloud"
  type    = "A"

  alias {
    name                   = module.eks-cluster.alb_dns_name           # 🔴 eks-cluster 모듈의 진짜 ALB 도메인 참조
    zone_id                = module.eks-cluster.alb_zone_id           # 🔴 eks-cluster 모듈의 진짜 ALB Zone ID 참조
    evaluate_target_health = true
  }
}

# 3. DB 서브 도메인 레코드 (Aurora MySQL 타겟팅 - 자동화)
resource "aws_route53_record" "db" {
  count   = var.environment == "prod" ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "db.team-train.cloud"
  type    = "CNAME"
  ttl     = "60"
  records = [module.database.aurora_writer_endpoint]
}
