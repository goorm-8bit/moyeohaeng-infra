variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "moyeohaeng"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr_block" {
  description = "VPC가 사용할 IP 주소 대역"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "서브넷들이 사용할 IP 주소 대역의 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "certificate_arn" {
  description = "HTTPS 리스너에 사용할 ACM 인증서의 ARN"
  type        = string
}
