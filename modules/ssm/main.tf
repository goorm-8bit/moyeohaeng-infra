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

# IAM
data "aws_caller_identity" "this" {}

# ECS 태스크 실행 역할에 추가할 'SSM 파라미터 읽기' 정책 생성
resource "aws_iam_policy" "ecs_ssm_role" {
  name = "${var.project_name}-ecs-ssm-role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = [
          aws_ssm_parameter.db_username.arn,
          aws_ssm_parameter.db_password.arn,
          aws_ssm_parameter.db_url.arn,
          aws_ssm_parameter.redis_host.arn,
          aws_ssm_parameter.redis_port.arn,
          aws_ssm_parameter.jwt_secret_key.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.this.account_id}:alias/aws/ssm"
      }
    ]
  })
}

# 위에서 만든 정책을 ECS 태스크 실행 역할에 연결
resource "aws_iam_role_policy_attachment" "ecs_ssm_role_policy" {
  policy_arn = aws_iam_policy.ecs_ssm_role.arn
  role       = var.ecs_task_execution_role_name
}
