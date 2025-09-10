output "asg_name" {
  description = "생성된 오토스케일링 그룹의 이름"
  value       = aws_autoscaling_group.this.name
}
