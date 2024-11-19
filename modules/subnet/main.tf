resource "aws_subnet" "dev-subnet-1" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet-cidr
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.Env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.Env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "${var.Env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "rtb-association" {
  subnet_id = aws_subnet.dev-subnet-1.id
  route_table_id = var.route_table_id
}
