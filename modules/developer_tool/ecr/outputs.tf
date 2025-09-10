output "repository_url" {
  description = "CI/CD 파이프라인에서 도커 이미지를 푸시할 ECR 리포지토리의 URL"
  value       = aws_ecr_repository.this.repository_url
}
