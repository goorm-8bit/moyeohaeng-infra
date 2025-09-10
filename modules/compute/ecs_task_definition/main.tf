resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-td"
  network_mode             = "awsvpc" # Task에 ENI를 할당하여 VPC 네트워크의 일원으로 직접 통신 가능
  requires_compatibilities = ["EC2"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.image_url
      essential = true # 컨테이너가 종료되면 태스크 전체가 중단
      portMappings = [
        {
          containerPort = 8080
        },
        {
          containerPort = 9090
        }
      ]
      environment = var.environment
      secrets     = var.secrets
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:9090/actuator/health || exit 1"
        ]
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-td"
  }
}
