output "task_definition_arn" {
  description = "ECS 서비스가 사용할 Task Definition의 ARN"
  value       = aws_ecs_task_definition.this.arn
}
