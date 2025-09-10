variable "project_name" {
  type = string
}

variable "lt_id" {
  description = "시작 템플릿의 ID"
  type        = string
}

variable "subnet_ids" {
  description = "EC2 인스턴스가 위치할 서브넷 ID의 목록"
  type        = list(string)
}

variable "min_size" {
  description = "유지할 최소 EC2 인스턴스 수"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "유지할 최대 EC2 인스턴스 수"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "평상시 유지할 EC2 인스턴스 수"
  type        = number
  default     = 2
}
