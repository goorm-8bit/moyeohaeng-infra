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
