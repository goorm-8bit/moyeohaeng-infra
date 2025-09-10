output "lt_id" {
  description = "오토스케일링 그룹에서 사용할 시작 템플릿의 ID"
  value       = aws_launch_template.this.id
}
