# 1. 그라파나용 보안 그룹 생성
resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-grafana-sg"
  description = "Security group for Grafana"
  vpc_id      = var.vpc_id

  # Ingress: ALB로부터 오는 3000번 포트 트래픽 허용
  ingress {
    description     = "Allow Grafana traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Egress: 외부로 나가는 모든 트래픽 허용 (프로메테우스, 로키 등과 통신)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-grafana-sg"
  }
}

# 2. 그라파나용 ECS 태스크 정의
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512

  # 그라파나 공식 도커 이미지 사용
  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana-oss:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project_name}-grafana-td"
  }
}

# 3. 그라파나용 ECS 서비스 생성 및 서비스 디스커버리 등록
resource "aws_ecs_service" "grafana" {
  name            = "${var.project_name}-grafana"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "grafana"
    container_port   = 3000
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.grafana.id]
  }

  # 서비스 디스커버리 설정
  # ECS 태스크가 시작되거나 종료될 때, IP를 자동으로 DNS에 등록/해제
  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }
}

# 4. 그라파나용 서비스 디스커버리 서비스 생성
# VPC 내부의 다른 서비스들이 이름으로 이 서비스를 찾을 수 있도록 Cloud Map에 등록
resource "aws_service_discovery_service" "grafana" {
  name = "grafana" # 이 서비스를 찾을 때 사용할 이름

  dns_config {
    namespace_id = var.private_dns_namespace_id # 이 서비스가 등록될 Private DNS 네임스페이스의 ID
    dns_records {
      ttl  = 10 # 짧게 설정하여 IP 변경에 빠르게 대응
      type = "A"
    }
    # 그라파나를 2개 이상 실행했을 때, DNS로 그라파나의 주소를 물어보면 건강한 컨테이너의 IP 주소를 최대 8개까지 반환
    routing_policy = "MULTIVALUE"
  }
}
