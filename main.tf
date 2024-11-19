provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr  
   tags = {
    Name = "${var.Env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myvpc.id
  Env_prefix = var.Env_prefix
  subnet-cidr = var.subnet-cidr
  avail_zone = var.avail_zone
  route_table_id = module.myapp-subnet.route_table_id
}


resource "aws_security_group" "my-sg" {
  vpc_id      = aws_vpc.myvpc.id
  
   ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   
   ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.Env_prefix}-sg"
  }
}

data "aws_ami" "latest-image" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.ec2_public_key)
}

resource "aws_instance" "dev-instance" {
  ami           = data.aws_ami.latest-image.id
  instance_type = var.instance_type
  subnet_id     = module.myapp-subnet.subnet.id
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y && sudo yum install -y docker
              sudo systemctl start docker 
              sudo usermod -aG docker ec2-user
              docker run -p 8080:80 nginx
              EOF


  tags = {
    Name = "${var.Env_prefix}-instance"
  }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-image.id
}

output "ec2_public_ip" {
    value = aws_instance.dev-instance.public_ip
}
