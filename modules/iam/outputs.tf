output "ecs_instance_profile_name" {
  description = "EC2 인스턴스에 연결할 IAM 인스턴스 프로파일의 이름"
  value       = aws_iam_instance_profile.ecs_instance_profile.name
}

output "ecs_task_execution_role_arn" {
  description = "ECS 태스크 실행 역할의 ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "ECS 태스크 실행 역할의 이름"
  value       = aws_iam_role.ecs_task_execution_role.name
}
