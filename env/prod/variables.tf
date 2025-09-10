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

variable "image_tag" {
  description = "컨테이너를 생성하는 데 사용할 ECR 이미지의 태그"
  type        = string
  default     = "latest"
}

variable "spring_secrets" {
  description = "컨테이너에 주입할 SSM 파라미터 스토어의 비밀 값 목록"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "spring_environment" {
  description = "컨테이너에 주입할 환경 변수 목록"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "CORS_ALLOWED_ORIGINS",
      value = "https://moyeohaeng.online,https://dev.moyeohaeng.online,http://localhost:5173"
    },
    {
      name  = "CORS_ALLOWED_METHODS",
      value = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    },
    {
      name  = "CORS_ALLOWED_HEADERS",
      value = "Authorization,Content-Type,Accept,Origin,X-Requested-With"
    }
  ]
}

variable "instance_type" {
  description = "EC2 인스턴스의 사양"
  type        = string
  default     = "t3.small"
}

variable "asg_min_size" {
  description = "유지할 최소 EC2 인스턴스 수"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "유지할 최대 EC2 인스턴스 수"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "평상시 유지할 EC2 인스턴스 수"
  type        = number
  default     = 2
}

variable "db_name" {
  description = "생성할 데이터베이스의 이름"
  type        = string
  default     = "moyeohaeng"
}

variable "db_username" {
  description = "데이터베이스 마스터 사용자의 이름"
  type        = string
  default     = "moyeohaeng"
}

variable "instance_class" {
  description = "DB 인스턴스의 사양"
  type        = string
  default     = "db.t4g.micro"
}
