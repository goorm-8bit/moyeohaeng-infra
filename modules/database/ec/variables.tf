variable "project_name" {
  type = string
}

variable "subnet_ids" {
  description = "ElastiCache가 위치할 서브넷 ID의 목록"
  type        = list(string)
}

variable "elasticache_sg_id" {
  description = "ElastiCache 클러스터에 적용할 보안 그룹의 ID"
  type        = string
}

variable "node_type" {
  description = "ElastiCache 클러스터의 노드 사양"
  type        = string
  default     = "cache.t4g.micro"
}
