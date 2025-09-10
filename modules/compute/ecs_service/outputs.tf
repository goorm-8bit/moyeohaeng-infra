output "service_name" {
  description = "생성된 ECS 서비스의 이름"
  value       = aws_ecs_service.this.name
}
