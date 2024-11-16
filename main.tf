resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"

    tags = {
        Name = "prod"
    }
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "prod-public-a"
  }
}
resource "aws_subnet" "public_c" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "prod-public-c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "prod"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "undefineddev-tf-state"

  tags = {
    Name        = "tf-state"
  }
}

