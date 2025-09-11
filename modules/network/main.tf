data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "this" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_route_table_association" "this" {
  count          = length(var.subnet_cidr_blocks)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this.id
}

# 모니터링 및 서비스 간 통신을 위한 Private DNS 네임스페이스 생성
# VPC 내부에서 서비스들이 이름(DNS)으로 서로 찾을 수 있게 만들어 주는 프라이빗 DNS 영역
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.project_name}.local"
  vpc  = aws_vpc.this.id

  # 서버 사이드 디스커버리
  # 클라이언트가 서비스 위치를 알 필요 없이, 서비스 등록과 라우팅을 서버(DNS, LB)가 대신 관리하는 방식
}
