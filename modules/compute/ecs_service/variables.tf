variable "project_name" {
  type = string
}

variable "cluster_id" {
  description = "ECS 서비스를 배포할 클러스터 ID"
  type        = string
}

variable "task_definition_arn" {
  description = "ECS 서비스가 실행할 Task Definition ARN"
  type        = string
}

variable "desired_count" {
  description = "실행할 태스크의 수"
  type        = number
  default     = 2
}

variable "subnet_ids" {
  description = "서비스의 태스크들이 위치할 서브넷 ID의 목록"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "서비스의 태스크들에 적용할 보안 그룹의 ID"
  type        = string
}

variable "target_group_arn" {
  default = "ECS 서비스가 실행하는 컨테이너를 연결할 Target Group의 ARN"
  type    = string
}

variable "container_name" {
  description = "로드밸런서와 연결할 컨테이너의 이름"
  type        = string
}

variable "container_port" {
  description = "로드밸런서가 트래픽을 전달할 컨테이너의 포트"
  type        = number
  default     = 8080
}

variable "private_dns_namespace_id" {
  description = "AWS Cloud Map Private DNS 네임스페이스의 ID"
  type        = string
}
