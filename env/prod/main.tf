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
  image_url          = "${module.ecr.repository_url}:${var.image_tag}"
  secrets            = var.spring_secrets
  environment        = var.spring_environment
  execution_role_arn = module.iam.ecs_task_execution_role_arn
}

# 7. ECS 서비스 모듈
module "ecs_service" {
  source              = "../../modules/compute/ecs-service"
  project_name        = var.project_name
  container_name      = var.project_name
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  subnet_ids          = module.network.subnet_ids
  ecs_sg_id           = module.sg.ecs_sg_id
  target_group_arn    = module.alb.target_group_arn
}

# 8. 시작 템플릿 모듈
module "lt" {
  source                    = "../../modules/compute/lt"
  project_name              = var.project_name
  instance_type             = var.instance_type
  cluster_name              = module.ecs_cluster.cluster_name
  ecs_sg_id                 = module.iam.ecs_instance_profile_name
  iam_instance_profile_name = module.sg.ecs_sg_id
}

# 9. 오토스케일링 그룹 모듈
module "asg" {
  source           = "../../modules/compute/asg"
  project_name     = var.project_name
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  lt_id            = module.lt.lt_id
  subnet_ids       = module.network.subnet_ids
}

# 10. ECR 모듈
module "ecr" {
  source       = "../../modules/developer_tool/ecr"
  project_name = var.project_name
}
