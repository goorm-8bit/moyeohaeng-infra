variable "aws_region" {
  default = "ap-northeast-2"
}

variable "project_name" {
  default = "moyeohaeng"
}

variable "vpc_cidr_block" {
  description = "VPC에 할당할 CIDR 블록"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "생성할 서브넷 CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "certificate_arn" {
  description = "ALB에 사용할 ACM 인증서의 ARN"
  type        = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}
