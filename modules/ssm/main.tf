# RDS
resource "aws_ssm_parameter" "db_url" {
  name      = "/${var.project_name}/DB_URL"
  type      = "String"
  value     = "jdbc:mysql://${var.db_instance_address}:${var.db_instance_port}/${var.db_name}?useSSL=false&allowPublicKeyRetrieval=true"
  overwrite = true
}

resource "aws_ssm_parameter" "db_username" {
  name      = "/${var.project_name}/DB_USERNAME"
  type      = "String"
  value     = var.db_username
  overwrite = true
}

resource "aws_ssm_parameter" "db_password" {
  name      = "/${var.project_name}/DB_PASSWORD"
  type      = "SecureString"
  value     = var.db_password
  overwrite = true
}

# ElastiCache
resource "aws_ssm_parameter" "redis_host" {
  name      = "/${var.project_name}/REDIS_HOST"
  type      = "String"
  value     = var.ec_primary_endpoint_address
  overwrite = true
}

resource "aws_ssm_parameter" "redis_port" {
  name      = "/${var.project_name}/REDIS_PORT"
  type      = "String"
  value     = var.ec_port
  overwrite = true
}

# JWT
resource "random_string" "jwt_secret_key" {
  length  = 64
  special = false
}

resource "aws_ssm_parameter" "jwt_secret_key" {
  name      = "/${var.project_name}/JWT_SECRET_KEY"
  type      = "SecureString"
  value     = base64encode(random_string.jwt_secret_key.result)
  overwrite = false
}
