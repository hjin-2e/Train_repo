# ==================
# 공통 변수
# ==================
variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev / prod)"
  type        = string
}

# ==================
# 배포 대상 (networking 모듈 output에서 주입)
# ==================
variable "frontend_bucket_name" {
  description = <<EOT
프론트엔드 정적 파일이 배포될 S3 버킷 이름.
module.networking.s3_frontend_bucket 값을 사용하세요.
EOT
  type        = string
}

variable "cloudfront_distribution_id" {
  description = <<EOT
캐시 무효화 대상 CloudFront 배포 ID.
module.networking.cloudfront_distribution_id 값을 사용하세요.
EOT
  type        = string
}

# ==================
# GitHub Actions OIDC 설정
# ==================
variable "github_repo" {
  description = <<EOT
GitHub Actions에서 AWS에 인증할 때 사용하는 레포지토리 정보.
"org/repo" 형태로 입력하세요. (예: "my-company/my-frontend-repo")
이 값은 IAM Role의 Trust Policy에 사용되어, 해당 레포에서만 역할을 수임할 수 있게 합니다.
EOT
  type        = string
}

variable "create_github_oidc_provider" {
  description = <<EOT
GitHub Actions OIDC Identity Provider를 신규 생성할지 여부.
AWS 계정에 이미 생성되어 있다면 false로 설정하세요.
(계정당 동일한 OIDC Provider URL은 하나만 존재 가능)
EOT
  type        = bool
  default     = true
}

# ==================
# 아티팩트 설정
# ==================
variable "artifact_object_key" {
  description = <<EOT
GitHub Actions가 S3에 업로드하는 배포 ZIP 파일의 S3 오브젝트 키.
CodePipeline Source Stage가 이 키를 감시합니다.
EOT
  type        = string
  default     = "frontend/deployment.zip"
}
