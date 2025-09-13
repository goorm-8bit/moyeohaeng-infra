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
  type        = string
}

variable "alb_sg_id" {
  description = "그라파나 접근을 허용할 ALB의 보안 그룹 ID"
  type        = string
}

variable "target_group_arn" {
  description = "그라파나 ECS 서비스에 연결할 Target Group의 ARN"
  type        = string
}

variable "cluster_id" {
  description = "ECS 클러스터의 ID"
  type        = string
}

variable "prometheus_config_content" {
  description = "프로메테우스 설정 파일(prometheus.yml)의 내용"
  type        = string
  sensitive   = true
}

variable "loki_config_content" {
  description = "로키 설정 파일(loki-config.yml)의 내용"
  type        = string
  sensitive   = true
}

variable "loki_s3_bucket_arn" {
  description = "로키 로그를 저장할 S3 버킷의 ARN"
  type        = string
}

variable "alloy_config_content" {
  description = "Alloy 설정 파일(config.river)의 내용"
  type        = string
  sensitive   = true
}

variable "ecs_instance_sg_id" {
  description = "Alloy가 실행되는 EC2 인스턴스의 보안 그룹 ID"
  type        = string
}

variable "grafana_admin_user" {
  description = "그라파나 관리자 ID"
  type        = string
}

variable "grafana_admin_password" {
  description = "그라파나 관리자 비밀번호"
  type        = string
  sensitive   = true
}
