variable "project_name" {
  type = string
}

# RDS
variable "db_instance_address" {
  description = "DB 인스턴스의 엔드포인트 주소"
  type        = string
}

variable "db_instance_port" {
  description = "DB 인스턴스의 포트"
  type        = number
}

variable "db_name" {
  description = "데이터베이스의 이름"
  type        = string
}

variable "db_username" {
  description = "데이터베이스 마스터 사용자의 이름"
  type        = string
}

variable "db_password" {
  description = "데이터베이스 마스터 사용자의 비밀번호"
  type        = string
  sensitive   = true
}

# ElastiCache
variable "ec_primary_endpoint_address" {
  description = "ElastiCache 클러스터의 기본 엔드포인트 주소"
  type        = string
}

variable "ec_port" {
  description = "ElastiCache 클러스터의 포트"
  type        = number
}

# IAM
variable "ecs_task_execution_role_name" {
  description = "SSM 파라미터 읽기 정책을 연결할 IAM 역할의 이름"
  type        = string
}

variable "aws_region" {
  description = "KMS 키 ARN을 구성하기 위한 AWS 리전"
  type        = string
}
