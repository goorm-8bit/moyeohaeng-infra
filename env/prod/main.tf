# 1. 네트워크 모듈
module "network" {
  source             = "../../modules/network"
  project_name       = var.project_name
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
}

# 2. 보안 그룹 모듈
module "sg" {
  source       = "../../modules/compute/sg"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
}

# 3. IAM 모듈
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

# 4. ALB 모듈
module "alb" {
  source          = "../../modules/compute/alb"
  project_name    = var.project_name
  certificate_arn = var.certificate_arn
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.subnet_ids
  alb_sg_id       = module.sg.alb_sg_id
}

# 5. ECS 클러스터 모듈
module "ecs_cluster" {
  source       = "../../modules/compute/ecs-cluster"
  project_name = var.project_name
}

# 6. ECS Task Definition 모듈
module "ecs_task_definition" {
  source             = "../../modules/compute/ecs-task-definition"
  project_name       = var.project_name
  image_url          = var.image_url
  secrets            = var.spring_secrets
  environment        = var.spring_environment
  execution_role_arn = module.iam.ecs_task_execution_role_arn
}
