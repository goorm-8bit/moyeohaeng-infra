output "spring_parameter_arns" {
  description = "생성된 모든 SSM 파라미터의 ARN"
  value = {
    SPRING_MYSQL_URL      = aws_ssm_parameter.db_url.arn
    SPRING_MYSQL_USERNAME = aws_ssm_parameter.db_username.arn
    SPRING_MYSQL_PASSWORD = aws_ssm_parameter.db_password.arn
    SPRING_REDIS_HOST     = aws_ssm_parameter.redis_host.arn
    SPRING_REDIS_PORT     = aws_ssm_parameter.redis_port.arn
    SPRING_JWT_SECRET_KEY = aws_ssm_parameter.jwt_secret_key.arn
  }
}
