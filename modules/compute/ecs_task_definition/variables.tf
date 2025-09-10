variable "project_name" {
  type = string
}

variable "execution_role_arn" {
  description = "ECS Task가 ECR 이미지 pull, Secret 접근 등에 사용할 IAM 역할의 ARN"
  type        = string
}

variable "image_url" {
  description = "컨테이너를 생성하는 데 사용할 도커 이미지의 URL"
  type        = string
}

variable "container_cpu" {
  description = "컨테이너에 할당할 CPU 유닛"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "컨테이너에 할당할 메모리"
  type        = number
  default     = 512
}

variable "secrets" {
  description = "컨테이너에 주입할 SSM 파라미터 스토어의 비밀 값 목록"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "environment" {
  description = "컨테이너에 주입할 환경 변수 목록"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
