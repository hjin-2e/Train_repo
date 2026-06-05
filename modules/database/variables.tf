# 넘겨받을 변수
variable "vpc_id" {
  description = "우리가 쓸 메인 VPC ID"
  type        = string
}
variable "db_subnet_ids" {
  description = "DB가 숨어있을 프라이빗 서브넷 ID 리스트"
  type        = list(string)
}
variable "private_subnet_ids" {
  description = "Redis가 숨어있을 프라이빗 서브넷 ID 리스트"
  type        = list(string)
}
variable "dms_subnet_ids" {
  description = "DMS 복제 인스턴스가 위치할 프라이빗 서브넷 ID 리스트"
  type        = list(string)
}
variable "dms_sg_id" {
  description = "네트워크 모듈에서 넘겨줄 DMS 보안그룹 ID"
  type        = string
}
variable "aurora_sg_id" {
  type        = string
  description = "네트워크 모듈에서 넘겨줄 Aurora SG ID"
}
variable "redis_sg_id" {
  type        = string
  description = "네트워크 모듈에서 넘겨줄 Redis SG ID"
}

# 보안/계정 변수
variable "db_admin_user" {
  description = "Aurora MySQL 마스터 계정 이름"
  type        = string
}

variable "db_admin_password" {
  description = "Aurora MySQL 마스터 비밀번호"
  type        = string
  sensitive   = true # 테라폼 로그에 비밀번호 안 찍히게 가려줌
}

# 인프라 스펙 변수
variable "dms_instance_class" {
  description = "DMS 복제 인스턴스 사양"
  type        = string
  default     = "dms.t3.micro" # dms.c5.large등 필요 시 늘리기
}

# Azure 정보 넣기
variable "azure_db_endpoint" {
  description = "Azure에서 띄운 MySQL 접속 주소"
  type        = string
}

variable "azure_db_user" {
  description = "Azure MySQL 계정"
  type        = string
}

variable "azure_db_password" {
  description = "Azure MySQL 비밀번호"
  type        = string
  sensitive   = true
}
