resource "aws_autoscaling_group" "this" {
  name                = "${var.project_name}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids

  # ASG가 인스턴스를 생성할 때 사용할 사용할 설계도
  launch_template {
    id      = var.lt_id
    version = "$Latest"
  }

  # ASG를 통해 생성되는 EC2 인스턴스에 적용할 태그
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.project_name}-ecs-instance"
  }
}
