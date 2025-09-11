output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "생성된 서브넷 ID의 목록"
  value       = aws_subnet.this[*].id
}

output "private_dns_namespace_id" {
  description = "생성된 Private DNS 네임스페이스의 ID"
  value       = aws_service_discovery_private_dns_namespace.this.id
}
