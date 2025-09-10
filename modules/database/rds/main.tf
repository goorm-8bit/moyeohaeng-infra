# 1. DB 서브넷 그룹 생성
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 2. 무작위 비밀번호 생성
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "!#%^&*()-_=+"
}

# 3. DB 인스턴스 생성
resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-mysql"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.this.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot    = true
  publicly_accessible    = true # Public IP 할당 (임시)

  tags = {
    Name = "${var.project_name}-mysql"
  }

  lifecycle {
    prevent_destroy = true # 삭제 방지
  }
}
