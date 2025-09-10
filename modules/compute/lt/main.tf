# 1. 최신 ECS 최적화 AMI 정보 가져오기
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# 2. 시작 템플릿(Launch Template) 생성
resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.instance_type
  user_data     = base64encode(base64encode("#!/bin/bash\necho ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config"))

  # EC2 인스턴스에 연결할 IAM 역할을 지정
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true # 인스턴스에 Public IP를 할당
    security_groups             = [var.ecs_sg_id]
  }

  tags = {
    Name = "${var.project_name}-lt"
  }
}
