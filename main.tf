terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terra-VPC"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "Terra-Gateway"
  }
}

resource "aws_route_table" "tf_public_route" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
  tags = {
    Name = "Terra-Public-RouteTable"
  }
}

resource "aws_subnet" "tf_public_subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Terraform-Subnet"
  }
}

resource "aws_route_table_association" "tf_public_assoc" {
  subnet_id          = aws_subnet.tf_public_subnet.id
  route_table_id     = aws_route_table.tf_public_route.id
}

resource "aws_security_group" "tf_public_sg" {
  name        = "tf_public_sg"
  description = "Used for access to the public instances"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terra-SecurityGroup"
  }
}

resource "aws_instance" "firstEC2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf_public_subnet.id
  vpc_security_group_ids = [aws_security_group.tf_public_sg.id]
  associate_public_ip_address = true
  key_name = "tf_key"
  user_data = <<-EOF
    sudo apt update
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
  EOF
  tags = {
    Name = "Ubuntu_Server1"
  }
}

resource "aws_instance" "secondEC2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf_public_subnet.id
  vpc_security_group_ids = [aws_security_group.tf_public_sg.id]
  key_name = "tf_key"
  user_data = <<-EOF
    sudo apt update
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
  EOF
  tags = {
    Name = "Ubuntu_Server2"
  }
}

resource "aws_instance" "thirdEC2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf_public_subnet.id
  vpc_security_group_ids = [aws_security_group.tf_public_sg.id]
  key_name = "tf_key"
  user_data = <<-EOF
    sudo apt update
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
  EOF
  tags = {
    Name = "Ubuntu_Server3"
  }
}
