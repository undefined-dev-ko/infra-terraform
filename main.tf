resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # 퍼블릭 IPv4 주소 자동 할당

  tags = {
    Name = "prod-public-a"
  }
}
resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.1.0/24"
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

resource "aws_instance" "prod" {
  ami           = "ami-0f1e61a80c7ab943e"
  instance_type = "t2.micro"

  tags = {
    Name = "prod"
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "undefineddev-tf-state"

  tags = {
    Name = "tf-state"
  }
}

resource "aws_s3_bucket" "deploy" {
  bucket = "undefineddev-for-deploy"

  tags = {
    Name = "deploy"
  }
}

resource "aws_ecr_repository" "prod" {
  name = "undefineddev/prod"
}

resource "aws_codedeploy_app" "prod" {
  name             = "undefineddev-prod"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.prod.name
  deployment_group_name  = "undefineddev-prod"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
}

# ec2 인스턴스에서 codedeploy agent 실행위한 IAM 역할
resource "aws_iam_role" "codedeploy_service_role" {
  name = "codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_service_role_policy" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}
