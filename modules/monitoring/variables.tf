variable "project_name" {
  type = string
}

variable "vpc_id" {
  description = "모니터링 서비스가 배포될 VPC의 ID"
  type        = string
}

variable "subnet_ids" {
  description = "ECS 서비스가 사용할 서브넷 ID 목록"
  type        = list(string)
}

variable "private_dns_namespace_id" {
  description = "AWS Cloud Map Private DNS 네임스페이스의 ID"
}

variable "aws_region" {
  description = "ARN 구성을 위한 AWS 리전"
  type        = string
}

variable "alb_sg_id" {
  description = "그라파나 접근을 허용할 ALB의 보안 그룹 ID"
  type        = string
}

variable "cluster_id" {
  default = "ECS 클러스터의 ID"
  type    = string
}
