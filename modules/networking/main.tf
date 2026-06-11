# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Public Subnet AZ-a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-public-a"
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
  }
}

# Public Subnet AZ-c
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-public-c"
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnet AZ-a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name                              = "${var.project_name}-private-a"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private Subnet AZ-c
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name                              = "${var.project_name}-private-c"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Elastic IP (NAT Gateway용)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

# NAT Gateway (Public Subnet에 위치)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name        = "${var.project_name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Public Route Table 연결
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table 연결
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}



#DB 서브넷 추가 
# DB Subnet AZ-a
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name        = "${var.project_name}-db-a"
    Environment = var.environment
  }
}

# DB Subnet AZ-c
resource "aws_subnet" "db_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name        = "${var.project_name}-db-c"
    Environment = var.environment
  }
}


# DB Route Table (route 제외하고 인터넷 경로 없음)
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-db-rt"
    Environment = var.environment
  }
}

# DB Route Table 연결
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "db_c" {
  subnet_id      = aws_subnet.db_c.id
  route_table_id = aws_route_table.db.id
}


# Aurora용 DB Subnet Group -> aurora 만들 때 서브넷 그룹 필수
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_c.id]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# 레디스 서브넷
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_c.id]

  tags = {
    Name        = "${var.project_name}-redis-subnet-group"
    Environment = var.environment
  }
}


#dms 복제 서브넷 그룹
resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "${var.project_name}-dms-subnet-group"
  replication_subnet_group_description = "DMS Replication Subnet Group sharing DB private subnets"
  subnet_ids                           = [aws_subnet.db_a.id, aws_subnet.db_c.id] # DB방에 같이 입주!

  tags = {
    Name        = "${var.project_name}-dms-subnet-group"
    Environment = var.environment
  }
}

