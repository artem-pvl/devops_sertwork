terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
  shared_credentials_file = "/root/.aws/credentials"
}

resource "tls_private_key" "awskey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "priv_key" {
    content     = tls_private_key.awskey.private_key_pem
    filename = "/root/.ssh/id_rsa"
    file_permission = "0600"
}

# resource "local_file" "pub_key" {
#     content     = tls_private_key.awskey.public_key_pem
#     filename = "/root/.ssh/id_rsa.pub"
#     file_permission = "0600"
# }

resource "aws_key_pair" "aws_key_t" {
  key_name   = "aws_key_t"
  public_key = tls_private_key.awskey.public_key_openssh
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all"

  ingress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0f7cd40eac2214b37"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = aws_key_pair.aws_key_t.key_name
  associate_public_ip_address = true

  tags = {
    Name = "web"
  }
}

resource "aws_instance" "build" {
  ami                    = "ami-0f7cd40eac2214b37"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = aws_key_pair.aws_key_t.key_name
  associate_public_ip_address = true

  tags = {
    Name = "build"
  }
}
