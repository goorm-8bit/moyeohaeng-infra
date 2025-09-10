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
