# 서브넷 그룹 이름
variable "db_subnet_group_name" {
  type = string
}
variable "redis_subnet_group_name" {
  type = string
}
variable "dms_subnet_group_name" {
  type = string
}

# 보안 그룹 id
variable "dms_sg_id" {
  type = string
}
variable "aurora_sg_id" {
  type = string
}
variable "redis_sg_id" {
  type = string
}

# Aurora MySQL 계정 정보
variable "db_admin_user" {
  type = string
}
variable "db_admin_password" {
  type      = string
  sensitive = true # 테라폼 로그에 비밀번호 안 찍히게 가려줌
}

# DMS 복제 인스턴스 사양
variable "dms_instance_class" {
  type    = string
  default = "dms.t3.small" # dms.c5.large등 필요 시 늘리기
}

# Azure 정보
# Azure에서 띄운 MySQL 접속 주소
variable "azure_db_endpoint" {
  type = string
}

# Azure MySQL 계정 정보
variable "azure_db_user" {
  type = string
}
variable "azure_db_password" {
  type      = string
  sensitive = true
}


# 프로젝트 이름과 환경 변수 추가
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}


variable "aurora_endpoint" {
  description = "Aurora Cluster Endpoint"
  type        = string
  default     = ""
}
