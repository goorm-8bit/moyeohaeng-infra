variable "project_name" {
  type = string
}

variable "subnet_ids" {
  description = "DB 인스턴스가 위치할 서브넷 ID의 목록"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "DB 인스턴스에 적용할 보안 그룹의 ID"
  type        = string
}

variable "db_name" {
  description = "생성할 데이터베이스의 이름"
  type        = string
}

variable "db_username" {
  description = "데이터베이스 마스터 사용자의 이름"
  type        = string
}

variable "instance_class" {
  description = "DB 인스턴스의 사양"
  type        = string
  default     = "db.t4g.micro"
}
