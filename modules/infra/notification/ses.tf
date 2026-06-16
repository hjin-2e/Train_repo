# 알림 발송용 이메일 주소 인증 신청
# 배포 후 해당 이메일함으로 AWS가 보낸 인증 확인 메일의 링크를 클릭해야 '인증됨'으로 바뀝니다.
resource "aws_ses_email_identity" "sender" {
  email = var.verified_email_or_domain
}

# SES 도메인 인증
resource "aws_ses_domain_identity" "email_domain" {
  domain = "team-train.cloud"
}

# Route53 DNS 레코드 자동 등록
resource "aws_route53_record" "ses_verification" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.email_domain.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.email_domain.verification_token]
}