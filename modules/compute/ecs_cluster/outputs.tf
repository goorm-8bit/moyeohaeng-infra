output "cluster_id" {
  description = "ECS 서비스를 생성할 때 필요한 클러스터의 ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "시작 템플릿에서 사용할 클러스터의 이름"
  value       = aws_ecs_cluster.this.name
}
