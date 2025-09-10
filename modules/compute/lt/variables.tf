variable "project_name" {
  type = string
}

variable "cluster_name" {
  description = "EC2 인스턴스가 등록될 ECS 클러스터의 이름"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스의 사양"
  type        = string
  default     = "t3.small"
}

variable "iam_instance_profile_name" {
  description = "ECS 클러스터의 EC2 인스턴스에 연결할 IAM 인스턴스 프로파일의 이름"
  type        = string
}

variable "ecs_sg_id" {
  description = "EC2 인스턴스에 적용할 보안 그룹의 ID"
  type        = string
}
