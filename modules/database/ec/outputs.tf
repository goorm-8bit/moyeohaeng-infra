output "primary_endpoint_address" {
  description = "SSM 파라미터 스토어에 저장할 ElastiCache 클러스터의 기본 엔드포인트 주소"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "port" {
  description = "SSM 파라미터 스토어에 저장할 ElastiCache 클러스터의 포트"
  value       = aws_elasticache_replication_group.this.port
}
