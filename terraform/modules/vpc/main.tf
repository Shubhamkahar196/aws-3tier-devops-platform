data "aws_availability_zones" "available" {
  state = "available"
}

# vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "dev"
  }
}


# internet gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# public subnet

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}"
    Tier        = "public"
    Project     = var.project_name
    Environment = "dev"
  }
}


# frontend privare subnets

resource "aws_subnet" "frontend" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = "10.0.${count.index + 11}.0/24"

  tags = {
    Name        = "${var.project_name}-frontend-${count.index + 1}"
    Tier        = "frontend"
    Project     = var.project_name
    Environment = "dev"

  }
}

# backend private subnet

resource "aws_subnet" "backend" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = "10.0.${count.index + 21}.0/24"

  tags = {
    Name        = "${var.project_name}-backend-${count.index + 1}"
    Tier        = "backend"
    Project     = var.project_name
    Environment = "dev"
  }
}


# database private subnet
resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = "10.0.${count.index + 31}.0/24"

  tags = {
    Name        = "${var.project_name}-database-${count.index + 1}"
    Tier        = "database"
    Project     = var.project_name
    Environment = "dev"
  }
}


# public route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# nat gateway

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name    = "${var.project_name}-nat-eip"
    Project = var.project_name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name    = "${var.project_name}-nat"
    Project = var.project_name
  }
}


# private route table

resource "aws_route_table" "private"{
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }
    tags={
        Name    = "${var.project_name}-private-rt"
    Project = var.project_name
    }
}

# private route table associations
resource "aws_route_table_association" "frontend"{
    count = length(aws_subnet.frontend)

    subnet_id = aws_subnet.frontend[count.index].id
    route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "backend" {
  count = length(aws_subnet.backend)

  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database"{
    count = length(aws_subnet.database)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.private.id
}
