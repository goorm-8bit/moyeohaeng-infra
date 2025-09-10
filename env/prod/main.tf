module "network" {
  source             = "../../modules/network"
  project_name       = var.project_name
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
}
