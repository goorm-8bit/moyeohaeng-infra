# 1. Application Load Balancer 생성
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application" # L7 로드밸런서
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# 2. Target Group 생성
# ALB가 트래픽을 최종적으로 전달할 대상(ECS 컨테이너)들의 그룹
resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # ALB가 ECS 컨테이너의 상태 확인
  health_check {
    path = "/actuator/health"
    port = "9090"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# 3. HTTP Listener 생성
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 4. HTTPS Listener 생성
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn # ACM에서 발급받은 인증서의 ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
