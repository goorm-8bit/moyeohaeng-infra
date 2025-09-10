output "cluster_id" {
  description = "ECS 서비스를 생성할 때 필요한 클러스터의 ID"
  value       = aws_ecs_cluster.this.id
}
