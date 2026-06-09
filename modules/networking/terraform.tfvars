# ==================
# 기본 설정
# ==================
project_name = "team-train"
environment  = "prod"
aws_region   = "ap-northeast-2"

# ==================
# 네트워크 설정
# ==================
developer_ips = [
  "개발자1 IP/32",  # 이하진
  "개발자2 IP/32",  # 이한비
  "개발자3 IP/32",  # 조재현
  "개발자4 IP/32"   # 강경보
]

# ==================
# Route53 설정
# CloudFront, ALB 생성 후 채워넣기
# ==================
cloudfront_domain_name = ""
cloudfront_zone_id     = "Z2FDTNDATAQYW2"
alb_dns_name           = ""
alb_zone_id            = ""

# ==================
# IAM + KMS 설정
# EKS 생성 후 채워넣기
# ==================
eks_oidc_provider_arn = ""
eks_oidc_provider     = ""

# ==================
# CloudTrail 설정
# ==================
cloudtrail_retention_days        = 90
cloudtrail_enable_log_validation = true
cloudtrail_multi_region          = true

# ==================
# EKS 관련
# 이하진님 EKS 생성 후 입력
# ==================
# eks_cluster_name     = ""
# eks_cluster_endpoint = ""
# eks_cluster_ca       = ""
# eks_cluster_token    = ""

# ==================
# IRSA Pod Role ARN
# iam.tf output 값 입력
# ==================
# booking_pod_role_arn = ""
# user_pod_role_arn    = ""
# payment_pod_role_arn = ""

# ==================
# DB Subnet IDs
# main.tf output 값 입력
# ==================
# db_subnet_ids = []