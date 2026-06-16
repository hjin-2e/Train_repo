# 알림 발송용 이메일 주소 인증 신청
# 배포 후 해당 이메일함으로 AWS가 보낸 인증 확인 메일의 링크를 클릭해야 '인증됨'으로 바뀝니다.
resource "aws_ses_email_identity" "sender" {
  email = var.verified_email_or_domain
}
