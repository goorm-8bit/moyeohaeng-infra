variable "project_name" {
  type = string
}

variable "vpc_id" {
  description = "ALB와 Target Group이 생성될 VPC의 ID"
  type        = string
}

variable "subnet_ids" {
  description = "ALB가 트래픽을 분산할 서브넷 ID의 목록"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ALB에 적용할 보안 그룹의 ID"
  type        = string
}

variable "certificate_arn" {
  description = "HTTPS 리스너에 사용할 ACM 인증서의 ARN"
  type        = string
}

variable "zone_name" {
  description = "Route 53 호스팅 영역의 이름"
  type        = string
}
