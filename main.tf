terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

#Resourcees for EC2 instance and security groups
#resource "aws_instance" "web" {
# ami           = var.ami
# instance_type = var.instance_type
# count         = 5

# tags = {
# Name = "${var.environment}-${count.index}"
# }
#}
# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic"
#   dynamic "ingress" {
#     for_each = var.sg_ports
#     iterator = port
#     content {
#       description = "TLS from VPC"
#       from_port   = port.value
#       to_port     = port.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
# }
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-_project"
  }
}
resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.my-vpc]
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "my-subnet"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "Demo_route_table"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.my-vpc.id
  depends_on = [aws_vpc.my-vpc]

  tags = {
    Name = "main"
  }
}
resource "aws_route_table_association" "my-route" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web"
  }
}
resource "tls_private_key" "tf_key" {
  algorithm = "RSA"
}
resource "aws_key_pair" "tf_keypair" {
  key_name   = "tf_key"
  public_key = tls_private_key.tf_key.public_key_openssh
}
resource "local_file" "tf_key" {

  content  = tls_private_key.tf_key.private_key_pem
  filename = "tf_key.pem"
}
resource "aws_instance" "instance_tf" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "tf_key"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = aws_subnet.subnet-1.id

  tags = {
    Name = "terraforminstance"
  }
}

