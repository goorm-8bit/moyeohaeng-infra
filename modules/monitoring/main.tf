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
      environment = [
        {
          name  = "GF_SECURITY_ADMIN_USER"
          value = var.grafana_admin_user
        },
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = var.grafana_admin_password
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q --spider http://localhost:3000/api/health || exit 1"
        ]
      }
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

# 5. 프로메테우스용 보안 그룹 생성
resource "aws_security_group" "prometheus" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Security group for Prometheus"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Prometheus traffic from Grafana/Alloy"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    security_groups = [
      aws_security_group.grafana.id,

      # Alloy가 host 모드로 동작하므로 EC2 인스턴스 SG 허용
      # host 모드는 컨테이너가 ENI를 가지지 않고, EC2의 네트워크 스택을 그대로 사용
      # 컨테이너가 바인딩하는 포트 = EC2 인스턴스에서 열려 있는 포트
      var.ecs_instance_sg_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-prometheus-sg"
  }
}

# 6. 프로메테우스용 ECS 태스크 정의
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.project_name}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9090
        }
      ]

      # 1. 컨테이너 시작 시 실행할 명령 정의
      # command로 전달하는 문자열을, 하나의 독립된 셸 스크립트로 해석해서 실행
      entryPoint = ["/bin/sh", "-c"]
      command = [
        # 환경 변수(PROMETHEUS_YML)의 내용을 파일로 저장하고, 그 파일을 사용해 프로메테우스 실행
        "echo \"$PROMETHEUS_YML\" > /etc/prometheus/prometheus.yml && /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.enable-remote-write-receiver"
      ]

      # 2. 환경 변수를 통해 설정 파일 내용을 주입
      environment = [
        {
          name  = "PROMETHEUS_YML"
          value = var.prometheus_config_content
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q --spider http://localhost:9090/-/healthy || exit 1"
        ]
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-prometheus-td"
  }
}

# 7. 프로메테우스용 ECS 서비스 생성 및 서비스 디스커버리 등록
resource "aws_ecs_service" "prometheus" {
  name            = "${var.project_name}-prometheus"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.prometheus.id]
  }

  # 서비스 디스커버리 설정
  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }
}

# 8. 프로메테우스용 서비스 디스커버리 서비스 생성
resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id = var.private_dns_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# 9. 로키가 S3 버킷에 접근할 수 있도록 허용하는 IAM 정책 생성
resource "aws_iam_policy" "loki_s3" {
  name = "${var.project_name}-loki-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          var.loki_s3_bucket_arn,
          "${var.loki_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# 10. 로키 태스크가 사용할 IAM 역할에 S3 정책 연결
resource "aws_iam_role" "loki_task_role" {
  name = "${var.project_name}-loki-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "loki_s3" {
  policy_arn = aws_iam_policy.loki_s3.arn
  role       = aws_iam_role.loki_task_role.name
}

# 11. 로키용 보안 그룹 생성
resource "aws_security_group" "loki" {
  name        = "${var.project_name}-loki-sg"
  description = "Security group for Loki"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Loki traffic from Grafana/Alloy"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    security_groups = [
      aws_security_group.grafana.id,
      var.ecs_instance_sg_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-loki-sg"
  }
}

# 12. 로키용 ECS 태스크 정의
resource "aws_ecs_task_definition" "loki" {
  family                   = "${var.project_name}-loki"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.loki_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "loki"
      image     = "grafana/loki:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3100
          hostPort      = 3100
        }
      ]
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "echo \"$LOKI_CONFIG_YML\" > /etc/loki/config.yml && /usr/bin/loki -config.file=/etc/loki/config.yml"
      ]
      environment = [
        {
          name  = "LOKI_CONFIG_YML"
          value = var.loki_config_content
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q --spider http://localhost:3100/ready || exit 1"
        ]
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-loki-td"
  }
}

# 13. 로키용 ECS 서비스 생성 및 서비스 디스커버리 등록
resource "aws_ecs_service" "loki" {
  name            = "${var.project_name}-loki"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.loki.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.loki.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.loki.arn
  }
}

# 14. 로키용 서비스 디스커버리 서비스 생성
resource "aws_service_discovery_service" "loki" {
  name = "loki"

  dns_config {
    namespace_id = var.private_dns_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# 15. Alloy가 ECS 서비스 디스커버리를 위해 사용할 IAM 정책
# Alloy가 메트릭 수집 대상을 찾기 위해 ECS 정보를 읽도록 허용
resource "aws_iam_policy" "alloy_ecs_discovery" {
  name = "${var.project_name}-alloy-ecs-discovery"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:DescribeContainerInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alloy_ecs_discovery" {
  role       = aws_iam_role.loki_task_role.name
  policy_arn = aws_iam_policy.alloy_ecs_discovery.arn
}

# 16. Alloy용 보안 그룹 생성
resource "aws_security_group" "alloy" {
  name        = "${var.project_name}-alloy-sg"
  description = "Security group for Alloy"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 17. Alloy용 ECS 태스크 정의
resource "aws_ecs_task_definition" "alloy" {
  family                   = "${var.project_name}-alloy"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512

  # 로키와 동일한 역할을 사용하여 S3 접근 및 서비스 디스커버리 권한 획득
  task_role_arn = aws_iam_role.loki_task_role.arn

  # 호스트의 도커 소켓과 로그 파일에 접근하기 위한 볼륨 정의
  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }
  volume {
    name      = "docker-logs"
    host_path = "/var/lib/docker/containers"
  }

  container_definitions = jsonencode([
    {
      name      = "alloy"
      image     = "grafana/alloy:latest"
      essential = true

      # 호스트의 도커 소켓과 로그 디렉토리를 컨테이너에 마운트
      mountPoints = [
        {
          sourceVolume  = "docker-socket"
          containerPath = "/var/run/docker.sock"
          readOnly      = true
        },
        {
          sourceVolume  = "docker-logs"
          containerPath = "/var/lib/docker/containers"
          readOnly      = true
        }
      ]

      entryPoint = ["/bin/sh", "-c"]
      command = [
        "echo \"$ALLOY_CONFIG_RIVER\" > /etc/alloy/config.river && /bin/alloy run /etc/alloy/config.river"
      ]

      environment = [
        {
          name  = "ALLOY_CONFIG_RIVER"
          value = var.alloy_config_content
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project_name}-alloy-td"
  }
}

# 18. Alloy용 ECS 서비스 생성
resource "aws_ecs_service" "alloy" {
  name            = "${var.project_name}-alloy"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.alloy.arn

  # DAEMON: 클러스터의 모든 EC2 인스턴스에 이 태스크를 하나씩 실행
  scheduling_strategy = "DAEMON"
}
