output "alb_sg_id" {
  description = "ALB 보안 그룹의 ID"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "ECS 보안 그룹의 ID"
  value       = aws_security_group.ecs.id
}

output "db_sg_id" {
  description = "RDS 보안 그룹의 ID"
  value       = aws_security_group.rds.id
}

output "elasticache_sg_id" {
  description = "ElastiCache 보안 그룹의 ID"
  value       = aws_security_group.elasticache.id
}
