output "target_group_arn" {
  description = "ECS 서비스가 실행하는 컨테이너를 연결할 Target Group의 ARN"
  value       = aws_lb_target_group.this.arn
}

output "lb_dns_name" {
  description = "Route 53에서 ALB 레코드 생성에 사용할 Load Balancer의 DNS 이름"
  value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
  description = "Route 53에서 ALB 레코드 생성에 사용할 Load Balancer의 Zone ID"
  value       = aws_lb.this.zone_id
}

output "grafana_taget_group_arn" {
  description = "그라파나 ECS 서비스를 연결할 Target Group의 ARN"
  value       = aws_lb_target_group.grafana.arn
}
