locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# 1. 네트워크 모듈
module "network" {
  source             = "../../modules/network"
  project_name       = local.name_prefix
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
}

# 2. 보안 그룹 모듈
module "sg" {
  source       = "../../modules/compute/sg"
  project_name = local.name_prefix
  vpc_id       = module.network.vpc_id
}

# 3. IAM 모듈
module "iam" {
  source       = "../../modules/iam"
  project_name = local.name_prefix
}

# 4. ALB 모듈
module "alb" {
  source          = "../../modules/compute/alb"
  project_name    = local.name_prefix
  certificate_arn = var.certificate_arn
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.subnet_ids
  alb_sg_id       = module.sg.alb_sg_id
}

# 5. ECS 클러스터 모듈
module "ecs_cluster" {
  source       = "../../modules/compute/ecs_cluster"
  project_name = local.name_prefix
}

# 6. ECS Task Definition 모듈
module "ecs_task_definition" {
  source             = "../../modules/compute/ecs_task_definition"
  project_name       = local.name_prefix
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  image_url          = "${module.ecr.repository_url}:${var.image_tag}"
  environment        = var.spring_environment
  secrets = [for key, arn in module.ssm.spring_parameter_arns : {
    name      = key
    valueFrom = arn
  }]
}

# 7. ECS 서비스 모듈
module "ecs_service" {
  source              = "../../modules/compute/ecs_service"
  project_name        = local.name_prefix
  container_name      = local.name_prefix
  cluster_id          = module.ecs_cluster.cluster_id
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  subnet_ids          = module.network.subnet_ids
  ecs_sg_id           = module.sg.ecs_sg_id
  target_group_arn    = module.alb.target_group_arn
}

# 8. 시작 템플릿 모듈
module "lt" {
  source                    = "../../modules/compute/lt"
  project_name              = local.name_prefix
  instance_type             = var.instance_type
  cluster_name              = module.ecs_cluster.cluster_name
  ecs_sg_id                 = module.iam.ecs_instance_profile_name
  iam_instance_profile_name = module.sg.ecs_sg_id
}

# 9. 오토스케일링 그룹 모듈
module "asg" {
  source           = "../../modules/compute/asg"
  project_name     = local.name_prefix
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  lt_id            = module.lt.lt_id
  subnet_ids       = module.network.subnet_ids
}

# 10. ECR 모듈
module "ecr" {
  source       = "../../modules/developer_tool/ecr"
  project_name = local.name_prefix
}

# 11. RDS 모듈
module "rds" {
  source         = "../../modules/database/rds"
  project_name   = local.name_prefix
  db_name        = var.db_name
  db_username    = var.db_username
  instance_class = var.instance_class
  subnet_ids     = module.network.subnet_ids
  rds_sg_id      = module.sg.rds_sg_id
}

# 12. ElastiCache 모듈
module "ec" {
  source            = "../../modules/database/ec"
  project_name      = local.name_prefix
  node_type         = var.node_type
  subnet_ids        = module.network.subnet_ids
  elasticache_sg_id = module.sg.elasticache_sg_id
}

# 13. SSM 모듈
module "ssm" {
  source                      = "../../modules/ssm"
  project_name                = local.name_prefix
  db_instance_address         = module.rds.db_instance_address
  db_instance_port            = module.rds.db_instance_port
  db_name                     = module.rds.db_name
  db_username                 = module.rds.db_username
  db_password                 = module.rds.db_password
  ec_primary_endpoint_address = module.ec.primary_endpoint_address
  ec_port                     = module.ec.port
}

# 14. Route 53 모듈
module "route53" {
  source          = "../../modules/network/route53"
  zone_name       = var.zone_name
  record_name     = var.record_name
  target_dns_name = module.alb.lb_dns_name
  target_zone_id  = module.alb.lb_zone_id
}
