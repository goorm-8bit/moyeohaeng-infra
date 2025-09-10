# 1. ElastiCache 서브넷 그룹 생성
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-ec-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-ec-subnet-group"
  }
}

# 2. ElastiCache 복제 그룹 생성
resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.project_name}-valkey"
  description                = "${var.project_name} Valkey Cluster"
  engine                     = "valkey"
  engine_version             = "8.0"
  node_type                  = var.node_type
  port                       = 6379
  num_cache_clusters         = 1 # 생성할 캐시 노드의 수
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [var.elasticache_sg_id]
  automatic_failover_enabled = false # true로 설정하면 주 노드 장애 시 자동으로 예비 노드로 전환 (노드 2개 이상 필요)
  snapshot_retention_limit   = 0     # 자동 스냅샷 비활성화

  tags = {
    Name = "${var.project_name}-valkey"
  }
}
