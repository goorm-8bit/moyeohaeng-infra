output "db_instance_address" {
  description = "SSM 파라미터 스토어에 저장할 DB 인스턴스의 엔드포인트 주소"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "SSM 파라미터 스토어에 저장할 DB 인스턴스의 포트"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "SSM 파라미터 스토어에 저장할 데이터베이스의 이름"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "SSM 파라미터 스토어에 저장할 데이터베이스 마스터 사용자의 이름"
  value       = aws_db_instance.this.username
}

output "db_password" {
  description = "SSM 파라미터 스토어에 저장할 데이터베이스 마스터 사용자의 비밀번호"
  value       = random_password.this.result
  sensitive   = true
}
