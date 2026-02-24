data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_vpc" "nebo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "nebo_subnet" {
  vpc_id                  = aws_vpc.nebo_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "nebo_igw" {
  vpc_id = aws_vpc.nebo_vpc.id
}

resource "aws_route_table" "nebo_route_table" {
  vpc_id = aws_vpc.nebo_vpc.id
}

resource "aws_route" "nebo_route" {
  route_table_id         = aws_route_table.nebo_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nebo_igw.id
}

resource "aws_route_table_association" "nebo_table_assoc" {
  subnet_id      = aws_subnet.nebo_subnet.id
  route_table_id = aws_route_table.nebo_route_table.id
}

resource "aws_security_group" "nebo_sg" {
  name        = "asg_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.nebo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
