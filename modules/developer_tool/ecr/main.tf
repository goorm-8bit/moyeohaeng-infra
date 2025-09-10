resource "aws_ecr_repository" "this" {
  name = var.project_name

  tags = {
    Name = "${var.project_name}-ecr"
  }
}
