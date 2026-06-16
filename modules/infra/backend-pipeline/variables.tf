variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "github_repo" {
  description = "GitHub Actions에서 AWS에 인증할 때 사용하는 레포지토리 정보. (예: Chjjh605/Backend_Train)"
  type        = string
}
