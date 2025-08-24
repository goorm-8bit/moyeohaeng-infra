terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  count      = length(var.subnet_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_blocks[count.index]

  tags = {
    Name = "${var.project_name}-subnet-${count.index + 1}"
  }
}
