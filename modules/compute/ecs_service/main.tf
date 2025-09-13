# 서비스 디스커버리 서비스 생성
resource "aws_service_discovery_service" "app" {
  name = "service"

  dns_config {
    namespace_id = var.private_dns_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  # 태스크가 실행된 후, ALB의 상태 검사를 통과할 때까지 기다려주는 유예 시간(초)
  health_check_grace_period_seconds = 300

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # 서비스 디스커버리 설정
  service_registries {
    registry_arn = aws_service_discovery_service.app.arn
  }

  tags = {
    Name = "${var.project_name}-service"
  }

  lifecycle {
    # CI/CD 파이프라인에서 작업 정의를 업데이트할 때, 테라폼이 변경 사항을 감지하고 서비스가 롤백되는 것을 방지
    ignore_changes = [
      task_definition
    ]
  }
}
