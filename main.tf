provider "aws" {
  region = "us-east-1"
}

variable "vpc-cidr" {}
variable "dev-subnet-cidr-1" {}
variable "dev-subnet-cidr-2" {}

resource "aws_vpc" "Development-vpc" {
  cidr_block = var.vpc-cidr  
   tags = {
    Name = "Development-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.Development-vpc.id
  cidr_block = var.dev-subnet-cidr-1
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-subnet-1"
  }
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id = aws_vpc.Development-vpc.id
  cidr_block = var.dev-subnet-cidr-2
  availability_zone = "us-east-1b"
  tags = {
    Name = "dev-subnet-2"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "default-subnet-1" {
  vpc_id = data.aws_vpc.default.id
  cidr_block = "172.31.96.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "default-subnet-1"
  }
}

resource "aws_subnet" "default-subnet-2" {
  vpc_id = data.aws_vpc.default.id
  cidr_block = "172.31.112.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "default-subnet-2"
  }
}
