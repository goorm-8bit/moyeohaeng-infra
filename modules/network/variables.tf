variable "project_name" {
  type = string
}

variable "vpc_cidr_block" {
  description = "VPC가 사용할 IP 주소 대역"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "서브넷들이 사용할 IP 주소 대역의 목록"
  type        = list(string)
}
